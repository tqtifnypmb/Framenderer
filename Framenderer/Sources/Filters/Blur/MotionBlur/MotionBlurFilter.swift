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
        - parameter distance: the length of the motion blur effect.
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

    override func setUniformAttributs(context ctx: Context) {
        super.setUniformAttributs(context: ctx)
      
        let dx = cos(_angle * M_PI / 180)
        let dy = sin(_angle * M_PI / 180)
        
        let width = Double(ctx.inputWidth)
        let height = Double(ctx.inputWidth)
        
        let unit = sqrt(pow(1 / width, 2) + pow(1 / height, 2))
        let distance = unit * _distance
        _program.setUniform(name: "distance", value: GLfloat(distance))
        _program.setUniform(name: "direction", value: CGPoint(x: dx, y: dy))
        _program.setUniform(name: "unit", value: Float(unit))
    }
    
    override func buildProgram() throws {
        _program = try Program.create(fragmentSourcePath: "MotionBlurFragmentShader")
    }
}
