//
//  BaseStream.swift
//  Framenderer
//
//  Created by tqtifnypmb on 07/03/2017.
//  Copyright © 2017 tqtifnypmb. All rights reserved.
//

import Foundation
import CoreMedia

class BaseStream: NSObject, Stream {
    public var filters: [Filter] = []
    
    var _ctx: Context!
    var _additionalFilter: Filter?
    var _previewView: PreviewView?
    
    private let _frameSemaphore: DispatchSemaphore
    override init() {
        _frameSemaphore = DispatchSemaphore(value: 1)
        
        super.init()
    }
    
    func start() {}
    func stop() {}
    
    func feed(sampleBuffer sm: CMSampleBuffer, isFont: Bool) throws {
        if case .timedOut = _frameSemaphore.wait(timeout: DispatchTime.now()) {
            return
        }
        
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
                strong_self._frameSemaphore.signal()
                continuation = nil      // break the reference-cycle
            }
        }
        
        let input = try SMSampleInputFrameBuffer(sampleBuffer: sm, isFont: isFont)
        try starter.applyToFrame(context: _ctx, inputFrameBuffer:input, presentationTimeStamp: time, next: continuation)
    }
}
