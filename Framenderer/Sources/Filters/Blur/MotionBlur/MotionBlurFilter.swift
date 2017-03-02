//
//  MotionBlurFilter.swift
//  Framenderer
//
//  Created by tqtifnypmb on 13/12/2016.
//  Copyright © 2016 tqitfnypmb. All rights reserved.
//

import Foundation
import OpenGLES.ES3.gl
import OpenGLES.ES3.glext

public class MotionBlurFilter: BaseFilter {
    
    /**
        init a [Motion blur](https://en.wikipedia.org/wiki/Motion_blur) filter
     
        Blurs an image to simulate the effect of using a camera that moves 
        a specified angle and distance while capturing the image.
     
        - parameter angle: the angle of the motion blur
        - parameter length: the length of the motion blur effect.
     */
    public init(angle: Double, distance: Double = 20) {
        _angle = angle
        _distance = distance
        super.init()
    }
    
    private let _angle: Double
    private let _distance: Double
    
    override public var name: String {
        return "MotionBlurFilter"
    }

    override func setUniformAttributs(context: Context) {
        super.setUniformAttributs(context: context)
        
        let width = Double(context.inputWidth)
        let height = Double(context.inputHeight)
        let aspectRatio = width / height
        let dx = _distance * cos(_angle * M_PI / 180) / (aspectRatio * height)
        let dy = _distance * sin(_angle * M_PI / 180) / height
        let samplerCount: Double = 7
        _program.setUniform(name: kXOffset, value: GLfloat(dx / samplerCount))
        _program.setUniform(name: kYOffset, value: GLfloat(dy / samplerCount))
    }
    
    override func buildProgram() throws {
        _program = try Program.create(vertexSourcePath: "MotionBlurVertexShader", fragmentSourcePath: "MotionBlurFragmentShader")
    }
}
