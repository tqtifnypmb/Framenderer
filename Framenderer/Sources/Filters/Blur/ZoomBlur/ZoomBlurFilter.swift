//
//  ZoomBlurFilter.swift
//  Framenderer
//
//  Created by tqtifnypmb on 13/12/2016.
//  Copyright © 2016 tqitfnypmb. All rights reserved.
//

import Foundation
import CoreGraphics
import OpenGLES.ES3.gl
import OpenGLES.ES3.glext

public class ZoomBlurFilter: BaseFilter {
    
    /**
        init a [Zoom blur](https://en.wikipedia.org/wiki/Zoom_burst) filter
     
        - parameter center: specifies the center of blur effect **[0 <= x <= 1, 0 <= y <= 1]**
        - parameter radius: specifies the radius of blur effect
     */
    public init(center: CGPoint, radius: CGFloat) {
        precondition(CGRect(x: 0, y: 0, width: 1, height: 1).contains(center))
        
        _center = center
        _radius = radius
    }
    private let _center: CGPoint
    private let _radius: CGFloat
    
    override public var name: String {
        return "ZoomBlurFilter"
    }
    
    override func setUniformAttributs(context ctx: Context) {
        super.setUniformAttributs(context: ctx)
        
        let width = Double(ctx.inputWidth)
        let height = Double(ctx.inputWidth)
        
        _program.setUniform(name: "width", value: Float(width))
        _program.setUniform(name: "height", value: Float(height))
        _program.setUniform(name: "center", value: _center)
        _program.setUniform(name: "radius", value: GLfloat(_radius))
    }
    
    override func buildProgram() throws {
        _program = try Program.create(fragmentSourcePath: "ZoomBlurFragmentShader")
    }
}
