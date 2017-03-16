//
//  BaseStream.swift
//  Framenderer
//
//  Created by tqtifnypmb on 07/03/2017.
//  Copyright © 2017 tqtifnypmb. All rights reserved.
//

import Foundation
import CoreMedia
import AVFoundation

open class BaseStream: NSObject, Stream {
    public var filters: [Filter] = []
    
    var _ctx: Context!
    var _appendingFilters: [Filter] = []
    var _prependingFilters: [Filter] = []

    var _previewView: PreviewView?
    
    var _isFront = false
    var _guessRotation = false
    
    private let _frameSemaphore = DispatchSemaphore(value: 1)
    
    public func start() {}
    public func stop() {}
    
    /// Always check this before calling `feed(:)`
    func canFeed() -> Bool {
        if case .timedOut = _frameSemaphore.wait(timeout: DispatchTime.now()) {
            return false
        } else {
            return true
        }
    }
    
    func feed(audioBuffer sm: CMSampleBuffer) throws {
        var currentFilters: [Filter] = []
        
        for prepending in _prependingFilters {
            currentFilters.append(prepending)
        }
        
        currentFilters.append(contentsOf: filters)
        
        for appending in _appendingFilters {
            currentFilters.append(appending)
        }
        
        if let preview = _previewView {
            currentFilters.append(preview)
        }
        
        let starter = currentFilters.removeFirst()
        
        // ref: http://wiki.haskell.org/Continuation
        // Is Swift doing tail-recursion optimization ??
        var continuation: ((Context, CMSampleBuffer) throws -> Void)!
        continuation = {[weak self] ctx, sm in
            if self == nil {
                return
            }
            
            if !currentFilters.isEmpty {
                let filter = currentFilters.removeFirst()
                try filter.applyToAudio(context: ctx, sampleBuffer: sm, next: continuation)
            } else {
                continuation = nil
            }
        }
        
        try starter.applyToAudio(context: _ctx, sampleBuffer: sm, next: continuation)
    }
    
    /// Feed video sample to filters-apply-cycle
    func feed(videoBuffer sm: CMSampleBuffer) throws {
        let time: CMTime = CMSampleBufferGetPresentationTimeStamp(sm)
        
        var currentFilters: [Filter] = []
        
        for prepending in _prependingFilters {
            currentFilters.append(prepending)
        }
        
        currentFilters.append(contentsOf: filters)
        
        for appending in _appendingFilters {
            currentFilters.append(appending)
        }
        
        if let preview = _previewView {
            currentFilters.append(preview)
        }
        
        let starter = currentFilters.removeFirst()
        
        // ref: http://wiki.haskell.org/Continuation
        // Is Swift doing tail-recursion optimization ??
        var continuation: ((Context, InputFrameBuffer) throws -> Void)!
        continuation = {[weak self] ctx, input in
            guard let strong_self = self else { return }
            
            if !currentFilters.isEmpty {
                let filter = currentFilters.removeFirst()
                try filter.applyToFrame(context: ctx, inputFrameBuffer: input, presentationTimeStamp: time, next: continuation)
            } else {
                ctx.reset()
                strong_self._frameSemaphore.signal()
                continuation = nil      // break the reference-cycle
            }
        }
        
        let input = try SMSampleInputFrameBuffer(sampleBuffer: sm, isFront: _isFront, guessRotation: _guessRotation)
        try starter.applyToFrame(context: _ctx, inputFrameBuffer:input, presentationTimeStamp: time, next: continuation)
    }
}
