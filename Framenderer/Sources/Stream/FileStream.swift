//
//  FileStream.swift
//  Framenderer
//
//  Created by tqtifnypmb on 07/03/2017.
//  Copyright © 2017 tqtifnypmb. All rights reserved.
//

import Foundation
import AVFoundation

open class FileStream: Stream {

    public var filters: [Filter] = []
    
    var _ctx: Context!
    var _additionalFilter: Filter?
        
    private let _reader: AVAssetReader
    private let _output: AVAssetReaderOutput
    private let _frameSerialQueue: DispatchQueue
    private let _renderSemaphore: DispatchSemaphore!
    public init(srcURL: URL) throws {
        precondition(srcURL.isFileURL)
        
        _frameSerialQueue = DispatchQueue(label: "com.github.Framenderer.CameraSerial")
        _renderSemaphore = DispatchSemaphore(value: 1)
        
        let asset = AVAsset(url: srcURL)
        _reader = try AVAssetReader(asset: asset)
        _output = AVAssetReaderVideoCompositionOutput(videoTracks: asset.tracks, videoSettings: nil)
        
        assert(_reader.canAdd(_output))
        _reader.add(_output)
    }
    
    public func start() {
        guard _reader.status != .reading else { return }
        
        _ctx = Context()
        _ctx.enableInputOutputToggle = false
        
        _reader.startReading()
        
        _frameSerialQueue.async { [weak self] in
            guard let strong_self = self else { return }
            
            while strong_self._reader.status == .reading {
                if let sm = strong_self._output.copyNextSampleBuffer() {
                    strong_self.didOutput(samepleBuffer: sm)
                }
            }
        }
    }
    
    public func stop() {
        _reader.cancelReading()
    }
    
    private func didOutput(samepleBuffer sm: CMSampleBuffer?) {
        if case .timedOut = _renderSemaphore.wait(timeout: DispatchTime.now()) {
            return
        }
        
        _ctx.frameSerialQueue.async {[retainedBuffer = sm, weak self] in
            guard let strong_self = self else { return }
            
            do {
                strong_self._ctx.setAsCurrent()
                let time: CMTime = CMSampleBufferGetPresentationTimeStamp(retainedBuffer!)
                
                var currentFilters = strong_self.filters
                if let addition = strong_self._additionalFilter {
                    currentFilters.append(addition)
                }
                
                let starter = currentFilters.removeFirst()
                
                // ref: http://wiki.haskell.org/Continuation
                var continuation: ((Context, InputFrameBuffer) throws -> Void)!
                continuation = {[weak self] ctx, input in
                    guard let strong_self = self else { return }
                    
                    if !currentFilters.isEmpty {
                        let filter = currentFilters.removeFirst()
                        try filter.applyToFrame(context: ctx, inputFrameBuffer: input, presentationTimeStamp: time, next: continuation)
                    } else {
                        ctx.reset()
                        strong_self._renderSemaphore.signal()
                        continuation = nil      // break the reference-cycle
                    }
                }
                
                let input = try SMSampleInputFrameBuffer(sampleBuffer: retainedBuffer!, isFont: false)
                try starter.applyToFrame(context: strong_self._ctx, inputFrameBuffer:input, presentationTimeStamp: time, next: continuation)
            } catch {
                fatalError(error.localizedDescription)
            }
        }
    }
}
