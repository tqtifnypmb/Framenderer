//
//  MotionBlurFilter.swift
//  SwiftyImage
//
//  Created by tqtifnypmb on 13/12/2016.
//  Copyright © 2016 tqitfnypmb. All rights reserved.
//

import Foundation
import OpenGLES.ES3.gl
import OpenGLES.ES3.glext

class MotionBlurFilter: BaseFilter {
    
    /**
        init a [Motion blur](https://en.wikipedia.org/wiki/Motion_blur) filter
     
        - parameter angle: the angle of the motion blur
        - parameter length: the length of the motion blur effect.
     */
    init(angle: Double, velocity: Double = 3.0) {
        _angle = angle
        _velocity = velocity
        super.init()
        
    }
    private let _angle: Double
    private let _velocity: Double
    
    override func setUniformAttributs(context: Context) {
        super.setUniformAttributs(context: context)
        
        let width = Double(context.inputWidth)
        let height = Double(context.inputHeight)
        let aspectRatio = width / height
        let dx = _velocity * cos(_angle * M_PI / 180) / (aspectRatio * height)
        let dy = _velocity * sin(_angle * M_PI / 180) / height
        _program.setUniform(name: kXOffset, value: GLfloat(dx))
        _program.setUniform(name: kYOffset, value: GLfloat(dy))
    }
    
    override func buildProgram() throws {
        _program = try Program.create(vertexSourcePath: "MotionBlurVertexShader", fragmentSourcePath: "MotionBlurFragmentShader")
    }
}
