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

public class GaussianBlurFilter: Filter {
    public enum Implement {
        case box
        case normal
    }
    
    private let _radius: Int
    private let _impl: Implement
    
    /// specifies the maximum number of times 
    /// Box blur to mimic Gaussian blur
    public var boxPass: Int = 3
    
    /// sigma value used by Gaussian algorithm
    public var gaussianSigma: Double = 0
    
    /**
        init a [Gaussian blur](https://en.wikipedia.org/wiki/Gaussian_blur) filter
        
        - parameter radius: specifies the distance from the center of the blur effect.
        - parameter implement: specifies which implement to use.
            - box: mimic Gaussian blur by applying box blur mutiple times
            - normal: use Gaussian algorithm
     */
    public init(radius: Int = 3, implement: Implement = .normal) {
        _radius = radius
        _impl = implement
    }
    
    public var contentScaleMode: ContentScaleMode = .scaleToFill
    
    public var name: String {
        switch _impl {
        case .box:
            return "BoxGaussianBlurFilter"
        
        case .normal:
            return "NormalGaussianBlurFilter"
        }
    }
    
    public func apply(context: Context) throws {
        switch _impl {
        case .box:
            let blur = BoxGaussianBlurFilter(radius: _radius, pass: max(boxPass, 3))
            blur.contentScaleMode = contentScaleMode
            try blur.apply(context: context)
            
        case .normal:
            let blur = NormalGaussianBlurFilter(radius: _radius, sigma: gaussianSigma)
            try blur.apply(context: context)
        }
    }
    
    public func applyToFrame(context: Context, inputFrameBuffer: InputFrameBuffer, presentationTimeStamp time: CMTime, next: @escaping (Context, InputFrameBuffer) throws -> Void) throws {
        switch _impl {
        case .box:
            let blur = BoxGaussianBlurFilter(radius: _radius, pass: max(boxPass, 3))
            blur.contentScaleMode = contentScaleMode
            try blur.applyToFrame(context: context, inputFrameBuffer: inputFrameBuffer, presentationTimeStamp: time, next: next)
            
        case .normal:
            let blur = NormalGaussianBlurFilter(radius: _radius, sigma: gaussianSigma)
            try blur.applyToFrame(context: context, inputFrameBuffer: inputFrameBuffer, presentationTimeStamp: time, next: next)
        }
    }
    
    public func applyToAudio(context: Context, sampleBuffer: CMSampleBuffer, next: @escaping (Context, CMSampleBuffer) throws -> Void) throws {
        switch _impl {
        case .box:
            let blur = BoxGaussianBlurFilter(radius: _radius, pass: max(boxPass, 3))
            try blur.applyToAudio(context: context, sampleBuffer: sampleBuffer, next: next)
            
        case .normal:
            let blur = NormalGaussianBlurFilter(radius: _radius, sigma: gaussianSigma)
            try blur.applyToAudio(context: context, sampleBuffer: sampleBuffer, next: next)
        }
    }
}

// achieve gaussian blur by applying box blur multiply times
// based on: http://blog.ivank.net/fastest-gaussian-blur.html
private class BoxGaussianBlurFilter: Filter {
    
    private var _boxBlurSize: [Int] = []
    init(radius: Int, pass: Int) {
        _boxBlurSize = calculateBoxBlurSize(radius: radius, pass: pass)
    }
    
    var contentScaleMode: ContentScaleMode = .scaleToFill
    
    var name: String {
        return "BoxGaussianBlurFilter"
    }
    
    private func calculateBoxBlurSize(radius: Int, pass: Int) -> [Int] {
        let n = Double(pass)
        let r = Double(radius)
        let wIdeal = sqrt(12 * r * r / n + 1)
        var wl = Int(floor(wIdeal))
        if wl % 2 == 0 {
            wl -= 1
        }
        
        let wu = wl + 2
      
        let mIdeal = (12 * r * r - n * Double(wl) * Double(wl) - 4 * n * Double(wl) - 3 * n) / (-4 * Double(wl) - 4)
        let m = round(mIdeal)

        var ret: [Int] = []
        for i in 0 ..< pass {
            let size = Double(i) < m ? wl : wu
            ret.append(size)
        }
        return ret
    }
    
    func apply(context: Context) throws {
        var boxFilters: [BoxBlurFilter] = []
        
        // take advanges of program objects caching
        for size in _boxBlurSize {
            boxFilters.append(BoxBlurFilter(radius: size))
        }
        
        for box in boxFilters {
            try box.apply(context: context)
        }
    }
    
    func applyToFrame(context: Context, inputFrameBuffer:InputFrameBuffer, presentationTimeStamp time: CMTime, next: @escaping (Context, InputFrameBuffer) throws -> Void) throws {
        
    }
    
    func applyToAudio(context: Context, sampleBuffer: CMSampleBuffer, next: @escaping (Context, CMSampleBuffer) throws -> Void) throws {
        try next(context, sampleBuffer)
    }
}

private class NormalGaussianBlurFilter: TwoPassFilter {
    
    private let _radius: Int
    private let _sigma: Double
    
    override var name: String {
        return "NormalGaussianBlurFilter"
    }
    
    init(radius: Int, sigma: Double = 0) {
        precondition(sigma >= 0)
        
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
        
        super.init()
    }
    
    fileprivate override func setUniformAttributs(context ctx: Context) {
        super.setUniformAttributs(context: ctx)
        
        let texelWidth = 1 / GLfloat(ctx.inputWidth)
        _program.setUniform(name: kXOffset, value: texelWidth)
        _program.setUniform(name: kYOffset, value: GLfloat(0))
    }
    
    fileprivate override func setUniformAttributs2(context ctx: Context) {
        super.setUniformAttributs2(context: ctx)
        
        let texelHeight = 1 / GLfloat(ctx.inputHeight)
        _program2.setUniform(name: kXOffset, value: GLfloat(0))
        _program2.setUniform(name: kYOffset, value: texelHeight)
    }
    
    override func buildProgram() throws {
        let vertexSrc = buildSeparableKernelVertexSource(radius: _radius)
        
        let kernel = buildGaussianKernel(radius: _radius, sigma: _sigma)
        let fragmentSrc = buildGaussianFragmentShaderSource(radius: _radius, kernel: kernel)
        
        _program = try Program.create(vertexSource: vertexSrc, fragmentSource: fragmentSrc)
        _program2 = try Program.create(vertexSource: vertexSrc, fragmentSource: fragmentSrc)
    }
}
