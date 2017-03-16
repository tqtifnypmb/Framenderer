//
//  ImageCanvas.swift
//  Framenderer
//
//  Created by tqtifnypmb on 08/12/2016.
//  Copyright © 2016 tqitfnypmb. All rights reserved.
//

import UIKit

open class ImageCanvas: NSObject, Canvas {
    private let _origin: CGImage
    private var _result: CGImage?
    
    public var filters: [Filter] = []
    
    public init(image: CGImage) {
        _origin = image
    }
    
    public func process() throws {
        precondition(!filters.isEmpty)
        
        let ctx = Context()
        ctx.setAsCurrent()
        let inputFrameBuffer = try ImageInputFrameBuffer(image: _origin)
        ctx.setInput(input: inputFrameBuffer)
        
        if isSupportFastTexture() {
            //FIXME: - We should use gbra consistently
            let bgr_2_rgb = ComponentExchangeFilter(mode: .rgb_bgr_toggle)
            try bgr_2_rgb.apply(context: ctx)
        }
        
        for filter in filters {
            try filter.apply(context: ctx)
        }
        
        _result = ctx.processedImage()
        filters.removeAll()
    }
    
    public func processAsync(onCompletion: @escaping (_ isFinished: Bool, _ error: Error?) -> Void) {
        precondition(!filters.isEmpty)
        
        DispatchQueue.global(qos: .background).async {
            do {
                try self.process()
                onCompletion(true, nil)
            } catch {
                self._result = nil
                self.filters.removeAll()
                onCompletion(false, error)
            }
        }
    }
    
    public func processedImage() -> CGImage {
        return _result!
    }
}
