//
//  BoxBlurFilter.swift
//  Framenderer
//
//  Created by tqtifnypmb on 11/12/2016.
//  Copyright © 2016 tqitfnypmb. All rights reserved.
//

import Foundation
import OpenGLES.ES3.gl
import OpenGLES.ES3.glext

public class BoxBlurFilter: TwoPassFilter {
    
    private let _radius: Int
    
    /**
     init a [Box blur](https://en.wikipedia.org/wiki/Box_blur) filter
     
     - parameter radius: specifies the distance from the center of the blur effect.
     */
    public init(radius: Int = 4) {
        precondition(radius >= 1)
        
        _radius = radius
        super.init()
    }
    
    override public var name: String {
        return "BoxBlurFilter"
    }
    
    override func setUniformAttributs(context ctx: Context) {
        super.setUniformAttributs(context: ctx)
        
        let texelWidth = 1 / GLfloat(ctx.inputWidth)
        _program.setUniform(name: kXOffset, value: texelWidth)
        _program.setUniform(name: kYOffset, value: GLfloat(0))
        _program.setUniform(name: "radius", value: _radius)
    }
    
    override func setUniformAttributs2(context ctx: Context) {
        super.setUniformAttributs2(context: ctx)
        
        let texelHeight = 1 / GLfloat(ctx.inputHeight)
        _program2.setUniform(name: kXOffset, value: GLfloat(0))
        _program2.setUniform(name: kYOffset, value: texelHeight)
        _program2.setUniform(name: "radius", value: _radius)
    }
    
    override func buildProgram() throws {
        _program = try Program.create(fragmentSourcePath: "BoxBlurFragmentShader")
        _program2 = try Program.create(fragmentSourcePath: "BoxBlurFragmentShader")
    }
}
