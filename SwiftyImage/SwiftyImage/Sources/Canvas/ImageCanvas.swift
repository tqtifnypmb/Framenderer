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
        precondition(!filters.isEmpty)
        
        
        let ctx = Context()
        ctx.setAsCurrent()
        let inputFrameBuffer = try FrameBuffer(texture: _origin.cgImage!, rotation: .none)
        ctx.setInput(input: inputFrameBuffer)
        
        for filter in filters {
            try filter.apply(context: ctx)
        }
        
        #if DEBUG
            ProgramObjectsCacher.shared.check_finish()
        #endif
        
        _result = ctx.processedImage()
        filters.removeAll()
    }
    
    func processAsync(onCompletion: (Bool) -> Void) {
        precondition(!filters.isEmpty)
    }
    
    func processedImage() -> CGImage {
        return _result!
    }
}
