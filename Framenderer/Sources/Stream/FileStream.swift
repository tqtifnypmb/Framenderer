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
    private let _output: AVAssetReaderOutput
    private let _frameSerialQueue: DispatchQueue
    public init(srcURL: URL) throws {
        precondition(srcURL.isFileURL)
        
        _frameSerialQueue = DispatchQueue(label: "com.github.Framenderer.CameraSerial")
        
        let asset = AVAsset(url: srcURL)
        _reader = try AVAssetReader(asset: asset)
        _reader.timeRange = CMTimeRangeMake(kCMTimeZero, asset.duration)
        
        let videoTracks = asset.tracks(withMediaType: AVMediaTypeVideo)
        let outputAttrs: [String: Any] = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA,
                                          kCVPixelBufferIOSurfacePropertiesKey as String: [:]]
        
        let comp = AVAssetReaderVideoCompositionOutput(videoTracks: videoTracks, videoSettings: outputAttrs)
        comp.videoComposition = AVVideoComposition(propertiesOf: asset)
        _output = comp
        
        super.init()
        _guessRotation = false
        _allowDropFrameIfNeeded = false
        
        assert(_reader.canAdd(_output))
        _reader.add(_output)
    }
    
    public override func start() {
        guard _reader.status != .reading else { return }
        
        _ctx = Context()
        _ctx.enableInputOutputToggle = false
        
        guard _reader.startReading() else {
            fatalError("Can't read specified asset")
        }
        
        _frameSerialQueue.async { [weak self] in
            guard let strong_self = self else { return }
            
            while strong_self._reader.status == .reading {
                if let sm = strong_self._output.copyNextSampleBuffer() {
                    strong_self.didOutput(samepleBuffer: sm)
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
    
    private func didOutput(samepleBuffer sm: CMSampleBuffer) {
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
