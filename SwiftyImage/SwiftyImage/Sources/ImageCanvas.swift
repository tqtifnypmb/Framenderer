//
//  ImageCanvas.swift
//  SwiftyImage
//
//  Created by tqtifnypmb on 08/12/2016.
//  Copyright © 2016 tqitfnypmb. All rights reserved.
//

import UIKit

public class ImageCanvas: NSObject, Canvas {
    private let _origin: UIImage
    private var _result: CGImage?
    
    var filters: [Filter] = []
    
    init(image: UIImage) {
        _origin = image
    }
    
    func process() throws {
        guard !filters.isEmpty else { return }
        
        let ctx = Context()
        ctx.setAsCurrent()
        let inputFrameBuffer = try FrameBuffer(texture: _origin.cgImage!)
        ctx.setInput(input: inputFrameBuffer)
        
        for filter in filters {
            try filter.apply(context: ctx)
        }
        
        _result = ctx.processedImage()
    }
    
    func processAsync(_ onCompletion: (Bool) -> Void) {
        
    }
    
    func processedImage() -> CGImage {
        return _result!
    }
}
