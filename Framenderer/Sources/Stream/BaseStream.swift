//
//  BaseStream.swift
//  Framenderer
//
//  Created by tqtifnypmb on 07/03/2017.
//  Copyright © 2017 tqtifnypmb. All rights reserved.
//

import Foundation
import CoreMedia

open class BaseStream: NSObject, Stream {
    public var filters: [Filter] = []
    
    var _ctx: Context!
    var _additionalFilter: Filter?
    var _previewView: PreviewView?
    
    var _isFront = false
    var _guessRotation = false
    
    /// Allow to drop frames that can't be handled in time
    var _allowDropFrameIfNeeded = true
    
    private let _frameSemaphore = DispatchSemaphore(value: 1)
    
    public func start() {}
    public func stop() {}
    
    /// Always check this before calling `feed(:)`
    func canFeed() -> Bool {
        guard _allowDropFrameIfNeeded else { return true }
        
        if case .timedOut = _frameSemaphore.wait(timeout: DispatchTime.now()) {
            return false
        } else {
            return true
        }
    }
    
    /// Feed sample to filters-apply-cycle
    func feed(sampleBuffer sm: CMSampleBuffer) throws {
        let time: CMTime = CMSampleBufferGetPresentationTimeStamp(sm)
        
        var currentFilters = filters
        if let addition = _additionalFilter {
            currentFilters.append(addition)
        }
        
        if let preview = _previewView {
            currentFilters.append(preview)
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
                
                if strong_self._allowDropFrameIfNeeded {
                    strong_self._frameSemaphore.signal()
                }
                continuation = nil      // break the reference-cycle
            }
        }
        
        let input = try SMSampleInputFrameBuffer(sampleBuffer: sm, isFront: _isFront, guessRotation: _guessRotation)
        try starter.applyToFrame(context: _ctx, inputFrameBuffer:input, presentationTimeStamp: time, next: continuation)
    }
}
