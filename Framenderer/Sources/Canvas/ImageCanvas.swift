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
    
    public var filters: [Filter] = []
    
    public init(image: CGImage) {
        _origin = image
    }
    
    public func process() throws -> CGImage? {
        precondition(!filters.isEmpty)
        precondition(!Thread.current.isMainThread)
        
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
        
        let ret = ctx.processedImage()
        filters.removeAll()
        
        return ret
    }
    
    public func processAsync(onCompletion: @escaping (_ resultImage: CGImage?, _ error: Error?) -> Void) {
        precondition(!filters.isEmpty)
        
        DispatchQueue.global(qos: .background).async {
            do {
                let img = try self.process()
                onCompletion(img, nil)
            } catch {
                self.filters.removeAll()
                onCompletion(nil, error)
            }
        }
    }
}
