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
    public var gaussianSigma: Double = 3.0
    
    /**
        init a [Gaussian blur](https://en.wikipedia.org/wiki/Gaussian_blur) filter
        
        - parameter radius: specifies the distance from the center of the blur effect.
        - parameter implement: specifies which implement to use.
            - box: mimic Gaussian blur by applying box blur mutiple times
            - normal: use Gaussian algorithm
     */
    public init(radius: Int = 4, implement: Implement = .normal) {
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
    private var _kernel: [Double] = []
    private var _vertexShaderSrc: String!
    private var _fragmentShaderSrc: String!
    
    override var name: String {
        return "NormalGaussianBlurFilter"
    }
    
    init(radius: Int, sigma: Double) {
        // kernel size <= 6sigma is good enough
        // reference: https://en.wikipedia.org/wiki/Gaussian_blur
        _radius = min(radius, Int(floor(6 * sigma)))

        super.init()
        
        _kernel = buildKernel(sigma: sigma)
        _vertexShaderSrc = buildSeparableKernelVertexSource(radius: _radius)
        _fragmentShaderSrc = buildFragmentShaderSource()
    }
    
    private func buildKernel(sigma: Double) -> [Double] {
        var ret: [Double] = []
        var sumOfWeight: Double = 0
        
        let twoSigmaSquare = 2 * pow(sigma, 2)
        let constant = 1 / sqrt(twoSigmaSquare * M_PI)
        for i in 0 ..< _radius + 1 {
            let weight = constant * exp(-Double(i) / twoSigmaSquare)
            ret.append(weight)
            
            sumOfWeight += i == 0 ? weight : 2 * weight
        }
        
        // normalize
        return ret.map { $0 / sumOfWeight }
    }
    
    private func buildFragmentShaderSource() -> String {
        let kernelSize = _radius * 2 + 1
        
        var src = "#version 300 es                         \n"
                + "precision highp float;                  \n"
                + "in highp vec2 fTextCoor[\(kernelSize)]; \n"
                + "uniform sampler2D firstInput;           \n"
                + "out vec4 color;                         \n"
                + "void main() {                           \n"
                + "    vec4 acc = vec4(0.0);               \n"
        
        // Note: We already know that the passed in fTextCoor is
        //       in order : [center, center - 1, center + 1, center - 2, center + 2, ...]
        for i in 0 ..< kernelSize {
            let distance = i % 2 == 0 ? (i / 2) : (i / 2 + 1)
            let weight = _kernel[distance]
            src += "acc += texture(firstInput, fTextCoor[\(i)]) * \(weight); \n"
        }
        
        src += "color = acc;                               \n"
        src += "}                                          \n"
        return src
    }
    
    override func buildProgram() throws {
        _program = try Program.create(vertexSource: _vertexShaderSrc, fragmentSource: _fragmentShaderSrc)
        _program2 = try Program.create(vertexSource: _vertexShaderSrc, fragmentSource: _fragmentShaderSrc)
    }
}
