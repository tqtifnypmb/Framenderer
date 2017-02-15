//
//  ImageCanvas.swift
//  SwiftyImage
//
//  Created by tqtifnypmb on 08/12/2016.
//  Copyright © 2016 tqitfnypmb. All rights reserved.
//

import UIKit

open class ImageCanvas: NSObject, Canvas {
    private let _origin: UIImage
    private var _result: CGImage?
    
    public var filters: [Filter] = []
    
    public init(image: UIImage) {
        _origin = image
    }
    
    #if DEBUG
    deinit {
        ProgramObjectsCacher.shared.check_finish()
    }
    #endif
    
    public func process() throws {
        precondition(!filters.isEmpty)
        
        let ctx = Context()
        ctx.setAsCurrent()
        let inputFrameBuffer = try ImageInputFrameBuffer(image: _origin.cgImage!)
        ctx.setInput(input: inputFrameBuffer)
        
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
