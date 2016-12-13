//
//  GaussianBlurFilter.swift
//  SwiftyImage
//
//  Created by tqtifnypmb on 12/12/2016.
//  Copyright © 2016 tqitfnypmb. All rights reserved.
//

import Foundation
import OpenGLES.ES3.gl
import OpenGLES.ES3.glext

public class GaussianBlurFilter: Filter {
    enum Implement {
        case box
        case normal
    }
    
    let _radius: Int
    let _impl: Implement
    
    var boxPass: Int = 3
    var gaussianSigma: Double = 2.0
    
    init(radius: Int, implement: Implement = .box) {
        _radius = radius
        _impl = implement
    }
    
    func apply(context: Context) throws {
        switch _impl {
        case .box:
            let blur = BoxGaussianBlurFilter(radius: _radius, pass: max(boxPass, 3))
            try blur.apply(context: context)
            
        case .normal:
            let blur = NormalGaussianBlurFilter(radius: _radius, sigma: gaussianSigma)
            try blur.apply(context: context)
        }
    }
}

/// based on: http://blog.ivank.net/fastest-gaussian-blur.html
private class BoxGaussianBlurFilter: Filter {
    
    private var _boxBlurSize: [Int] = []
    init(radius: Int, pass: Int) {
        _boxBlurSize = calculateBoxBlurSize(radius: radius, pass: pass)
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
        for size in _boxBlurSize {
            let box = BoxBlurFilter(radius: size)
            try box.apply(context: context)
        }
    }
}

private class NormalGaussianBlurFilter: TwoPassFilter {
    
    private let _radius: Int
    private var _kernel: [Double] = []
    private var _vertexShaderSrc: String!
    private var _fragmentShaderSrc: String!
    
    init(radius: Int, sigma: Double) {
        // kernel size < 6sigma is good enough
        // reference: https://en.wikipedia.org/wiki/Gaussian_blur
        let goodEnoughSize = min(radius * 2 + 1, 6 * Int(floor(sigma)))
        _radius = max((goodEnoughSize - 1) / 2, 1)
        super.init()
        
        _kernel = buildKernel(sigma: sigma)
        _vertexShaderSrc = buildTwoPassVertexSource(radius: _radius)
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
        
        // Note: We already know that the pass in fTextCoor is
        //       in order : [center, center - 1, center + 1, center - 2, center + 2, ...]
        for i in 0 ..< kernelSize {
            let offset = i - _radius
            let weight = _kernel[abs(offset)]
            src += "acc += texture(firstInput, fTextCoor[\(i)]) * \(weight); \n"
        }
        
        src += "color = acc;                               \n"
        src += "}                                          \n"
        return src
    }
    
    override func buildProgram() throws {
        _program = try Program.create(vertexSource: _vertexShaderSrc, fragmentSource: _fragmentShaderSrc)
    }
    
    override func buildProgram2() throws {
        _program2 = try Program.create(vertexSource: _vertexShaderSrc, fragmentSource: _fragmentShaderSrc)
    }
}
