//
//  ZoomBlurFilter.swift
//  SwiftyImage
//
//  Created by tqtifnypmb on 13/12/2016.
//  Copyright © 2016 tqitfnypmb. All rights reserved.
//

import Foundation
import CoreGraphics
import OpenGLES.ES3.gl
import OpenGLES.ES3.glext

class ZoomBlurFilter: BaseFilter {
    
    /**
        init a [Zoom blur](https://en.wikipedia.org/wiki/Zoom_burst) filter
     
        - parameter center: specifies the center of blur effect **[0 <= x <= 1, 0 <= y <= 1]**
        - parameter size: specifies the size of blur effect
     */
    init(center: CGPoint, radius: CGFloat) {
        precondition(center.x >= 0 && center.x <= 1)
        precondition(center.y >= 0 && center.y <= 1)
        
        _center = center
        _radius = radius
    }
    private let _center: CGPoint
    private let _radius: CGFloat
    
    override func setUniformAttributs(context ctx: Context) {
        super.setUniformAttributs(context: ctx)
        
        let texelWidth = 1 / GLfloat(ctx.inputWidth)
        let texelHeight = 1 / GLfloat(ctx.inputHeight)
        //_program.setUniform(name: kTexelWidth, value: texelWidth)
       // _program.setUniform(name: kTexelHeight, value: texelHeight)
        _program.setUniform(name: "center", value: _center)
        _program.setUniform(name: "size", value: GLfloat(_radius))
    }
    
    override func buildProgram() throws {
        _program = try Program.create(vertexSourcePath: "PassthroughVertexShader", fragmentSourcePath: "ZoomBlurFragmentShader")
    }
}
