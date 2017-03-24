//
//  BilateralBlurFilter.swift
//  Framenderer
//
//  Created by tqtifnypmb on 20/03/2017.
//  Copyright © 2017 tqtifnypmb. All rights reserved.
//

import Foundation

public class BilateralBlurFilter: TwoPassFilter {
    
    private let _radius: Int
    private let _sigmaColor: Double
    private let _sigmaSpace: Double
    public init(radius: Int = 3, sigmaColor: Double = 0, sigmaSpace: Double = 0) {
        precondition(radius > 0)
        
        _radius = radius
        
        if sigmaColor == 0 {
            // source from OpenCV (http://docs.opencv.org/3.2.0/d4/d86/group__imgproc__filter.html)
            _sigmaColor = 0.3 * Double(radius - 1) + 0.8
        } else {
            _sigmaColor = sigmaColor
        }
        
        if sigmaSpace == 0 {
            _sigmaSpace = 0.3 * Double(radius - 1) + 0.8
        } else {
            _sigmaSpace = sigmaSpace
        }
    }
    
    override public var name: String {
        return "BilateralBlurFilter"
    }
    
    override func buildProgram() throws {
        _program = try Program.create(fragmentSourcePath: "BilateralBlurFragmentShader")
        _program2 = try Program.create(fragmentSourcePath: "BilateralBlurFragmentShader")
    }
    
    override func setUniformAttributs(context ctx: Context) {
        super.setUniformAttributs(context: ctx)
        
        let texelWidth = 1 / GLfloat(ctx.inputWidth)
        _program.setUniform(name: kXOffset, value: texelWidth)
        _program.setUniform(name: kYOffset, value: GLfloat(0))
        
        _program.setUniform(name: "radius", value: _radius)
        _program.setUniform(name: "colorSigma", value: Float(_sigmaColor))
        _program.setUniform(name: "spaceSigma", value: Float(_sigmaSpace))
    }
    
    override func setUniformAttributs2(context ctx: Context) {
        super.setUniformAttributs2(context: ctx)
        
        let texelHeight = 1 / GLfloat(ctx.inputHeight)
        _program2.setUniform(name: kXOffset, value: GLfloat(0))
        _program2.setUniform(name: kYOffset, value: texelHeight)
        
        _program2.setUniform(name: "radius", value: _radius)
        _program2.setUniform(name: "colorSigma", value: Float(_sigmaColor))
        _program2.setUniform(name: "spaceSigma", value: Float(_sigmaSpace))
    }
}
