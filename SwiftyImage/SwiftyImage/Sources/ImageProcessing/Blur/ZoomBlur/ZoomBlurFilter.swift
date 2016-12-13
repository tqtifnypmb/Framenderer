//
//  ZoomBlurFilter.swift
//  SwiftyImage
//
//  Created by tqtifnypmb on 13/12/2016.
//  Copyright © 2016 tqitfnypmb. All rights reserved.
//

import Foundation
import CoreGraphics

class ZoomBlurFilter: BaseFilter {
    
    /**
        init a [Zoom blur](https://en.wikipedia.org/wiki/Zoom_burst) filter
     
        - parameter center: specifies the center of blur effect **[0 <= x <= 1, 0 <= y <= 1]**
        - parameter size: specifies the size of blur effect
     */
    init(center: CGPoint, size: CGFloat) {
        precondition(center.x >= 0 && center.x <= 1)
        precondition(center.y >= 0 && center.y <= 1)
        
        _center = center
        _size = size
    }
    private let _center: CGPoint
    private let _size: CGFloat
    
    override func buildProgram() throws {
        _program = try Program.create(vertexSourcePath: "PassthroughVertexShader", fragmentSourcePath: "ZoomBlurFragmentShader")
    }
}
