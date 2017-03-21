//
//  GaussianBlurFilter.swift
//  Framenderer
//
//  Created by tqtifnypmb on 12/12/2016.
//  Copyright © 2016 tqitfnypmb. All rights reserved.
//

import Foundation
import OpenGLES.ES3.gl
import OpenGLES.ES3.glext
import CoreMedia
import AVFoundation

public class GaussianBlurFilter: TwoPassFilter {
    private let _radius: Int
    private let _sigma: Double
    
    /// sigma value used by Gaussian algorithm
    public var gaussianSigma: Double = 0
    
    /**
        init a [Gaussian blur](https://en.wikipedia.org/wiki/Gaussian_blur) filter
        
        - parameter radius: specifies the distance from the center of the blur effect.
        - parameter implement: specifies which implement to use.
            - box: mimic Gaussian blur by applying box blur mutiple times
            - normal: use Gaussian algorithm
     */
    public init(radius: Int = 3, sigma: Double = 0) {
        if sigma == 0 {
            _radius = radius
            
            // source from OpenCV (http://docs.opencv.org/3.2.0/d4/d86/group__imgproc__filter.html)
            _sigma = 0.3 * Double(_radius - 1) + 0.8
        } else {
            // kernel size <= 6sigma is good enough
            // reference: https://en.wikipedia.org/wiki/Gaussian_blur
            _radius = min(radius, Int(floor(6 * sigma)))
            _sigma = sigma
        }
    }
    
    override public var name: String {
        return "GaussianBlurFilter"
    }
    
    override public func setUniformAttributs(context ctx: Context) {
        super.setUniformAttributs(context: ctx)
        
        let texelWidth = 1 / GLfloat(ctx.inputWidth)
        _program.setUniform(name: kXOffset, value: texelWidth)
        _program.setUniform(name: kYOffset, value: GLfloat(0))
        _program.setUniform(name: "radius", value: Float(_radius))
        _program.setUniform(name: "sigma", value: Float(_sigma))
    }
    
    override public func setUniformAttributs2(context ctx: Context) {
        super.setUniformAttributs2(context: ctx)
        
        let texelHeight = 1 / GLfloat(ctx.inputHeight)
        _program2.setUniform(name: kXOffset, value: GLfloat(0))
        _program2.setUniform(name: kYOffset, value: texelHeight)
        _program2.setUniform(name: "radius", value: Float(_radius))
        _program2.setUniform(name: "sigma", value: Float(_sigma))
    }
    
    override func buildProgram() throws {
        _program = try Program.create(fragmentSourcePath: "GaussianBlurFragmentShader")
        _program2 = try Program.create(fragmentSourcePath: "GaussianBlurFragmentShader")
    }
}
