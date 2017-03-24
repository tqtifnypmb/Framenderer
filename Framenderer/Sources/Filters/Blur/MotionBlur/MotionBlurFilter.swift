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
        - parameter radius: the length of the motion blur effect.
     */
    public init(angle: Double, radius: Double = 20) {
        precondition(radius >= 0.0)
        
        _angle = angle
        _radius = radius
        super.init()
    }
    
    private let _angle: Double
    private let _radius: Double
    
    override public var name: String {
        return "MotionBlurFilter"
    }

    override func setUniformAttributs(context ctx: Context) {
        super.setUniformAttributs(context: ctx)
      
        let dx = cos(_angle * M_PI / 180)
        let dy = sin(_angle * M_PI / 180)
        
        let width = Double(ctx.inputWidth)
        let height = Double(ctx.inputWidth)
        
        let xUnit = abs(dx / width)
        let yUnit = abs(dy / height)
        
        var unit: Double = 0
        if dy != 0 && dx != 0 {
            unit = abs(sqrt(pow(1 / width / dx, 2) + pow(1 / height / dy, 2)))
        } else if dy == 0 {
            unit = 1 / width / dx
        } else if dx == 0 {
            unit = 1 / width / dy
        }

        let radius = unit * _radius
        _program.setUniform(name: "radius", value: GLfloat(radius))
        _program.setUniform(name: "offset", value: CGPoint(x: xUnit, y: yUnit))
        _program.setUniform(name: "unit", value: Float(unit))
    }
    
    override func buildProgram() throws {
        _program = try Program.create(fragmentSourcePath: "MotionBlurFragmentShader")
    }
}
