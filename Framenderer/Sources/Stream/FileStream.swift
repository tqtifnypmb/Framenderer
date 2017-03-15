//
//  FileStream.swift
//  Framenderer
//
//  Created by tqtifnypmb on 07/03/2017.
//  Copyright © 2017 tqtifnypmb. All rights reserved.
//

import Foundation
import AVFoundation

open class FileStream: BaseStream {    
    
    private let _reader: AVAssetReader
    private let _video: AVAssetReaderOutput
    private let _audio: AVAssetReaderOutput
    private let _frameSerialQueue: DispatchQueue
    public init(srcURL: URL) throws {
        precondition(srcURL.isFileURL)
        
        _frameSerialQueue = DispatchQueue(label: "com.github.Framenderer.CameraSerial")
        
        let asset = AVAsset(url: srcURL)
        _reader = try AVAssetReader(asset: asset)
        _reader.timeRange = CMTimeRangeMake(kCMTimeZero, asset.duration)
        
        // always first track ?
        let videoTrack = asset.tracks(withMediaType: AVMediaTypeVideo).first!
        let decompressSetttings: [String: Any] = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA,
                                          kCVPixelBufferIOSurfacePropertiesKey as String: [:]]
        _video = AVAssetReaderTrackOutput(track: videoTrack, outputSettings: decompressSetttings)
        
//        let video = AVAssetReaderVideoCompositionOutput(videoTracks: videoTracks, videoSettings: outputAttrs)
//        video.videoComposition = AVVideoComposition(propertiesOf: asset)
//        _video = video
        
        // always first track ?
        let audioTrack = asset.tracks(withMediaType: AVMediaTypeAudio).first!
        _audio = AVAssetReaderTrackOutput(track: audioTrack, outputSettings: nil)
        
        super.init()
        _guessRotation = false
        
        assert(_reader.canAdd(_video))
        _reader.add(_video)
        
        assert(_reader.canAdd(_audio))
        _reader.add(_audio)
    }
    
    public override func start() {
        guard _reader.status != .reading else { return }
        
        _ctx = Context()
        _ctx.enableInputOutputToggle = false
        
        guard _reader.startReading() else {
            fatalError("Can't read specified asset")
        }
        
        var firstAudioSample = _audio.copyNextSampleBuffer()
        let writer = self._additionalFilter as? FrameWriter
        do {
            try writer?.prepareAudioInput(sampleBuffer: firstAudioSample!)
        } catch {
            fatalError(error.localizedDescription)
        }
        
        _frameSerialQueue.async { [weak self] in
            guard let strong_self = self else { return }
            
            while strong_self._reader.status == .reading {
                if let sm = strong_self._video.copyNextSampleBuffer() {
                    strong_self.didOutputVideo(sampleBuffer: sm)
                } else {
                    if strong_self._reader.status == .failed {
                        fatalError(strong_self._reader.error!.localizedDescription)
                    } else {
                        break
                    }
                }
            }
        }
        
        _frameSerialQueue.async { [weak self] in
            self?.didOutputAudio(sampleBuffer: firstAudioSample!)
            firstAudioSample = nil
        }
        
        _frameSerialQueue.async { [weak self] in
            guard let strong_self = self else { return }
            
            while strong_self._reader.status == .reading {
                if let sm = strong_self._audio.copyNextSampleBuffer() {
                    strong_self.didOutputAudio(sampleBuffer: sm)
                } else {
                    if strong_self._reader.status == .failed {
                        fatalError(strong_self._reader.error!.localizedDescription)
                    } else {
                        strong_self.eof()
                    }
                }
            }
        }
    }
    
    public override func stop() {
        _reader.cancelReading()
    }
    
    func eof() {}
    
    private func didOutputAudio(sampleBuffer sm: CMSampleBuffer) {
        _ctx.audioSerialQueue.async {[weak self] in
            do {
                try self?.feed(audioBuffer: sm)
            } catch {
                fatalError(error.localizedDescription)
            }
        }
    }
    
    private func didOutputVideo(sampleBuffer sm: CMSampleBuffer) {
        guard self.canFeed() else { return }
                
        _ctx.frameSerialQueue.async {[retainedBuffer = sm, weak self] in
            do {
                try self?.feed(videoBuffer: retainedBuffer)
            } catch {
                fatalError(error.localizedDescription)
            }
        }
    }
}
