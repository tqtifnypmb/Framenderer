//
//  AdaptiveThresholdFilter.swift
//  Framenderer
//
//  Created by tqtifnypmb on 20/03/2017.
//  Copyright © 2017 tqtifnypmb. All rights reserved.
//

import Foundation

public class AdaptiveThresholdFilter: BaseFilter {
    public enum Method: Int {
        case mean = 0
        case gaussian = 1
    }
    
    private let _max: Float
    private let _radius: Int
    private let _method: Method
    private let _type: ThresholdType
    public init(max: Float, radius: Int, method: Method, type: ThresholdType) {
        _max = max
        _radius = radius
        _method = method
        _type = type
    }
    
    override public var name: String {
        return "AdaptiveThresholdFilter"
    }
    
    override func buildProgram() throws {
        var fragmentSrc: String!
        
        switch _method {
        case .mean:
            let kernelSize = pow(Double(_radius * 2 + 1), 2.0)
            let weight = 1.0 / kernelSize
            fragmentSrc = buildFragmentShaderSource(kernel: [Double](repeating: weight, count: Int(kernelSize)))
            
        case .gaussian:
            let sigma = 0.3 * Double(_radius - 1) + 0.8
            let kernel = buildKernel(radius: _radius, sigma: sigma)
            
            fragmentSrc = buildFragmentShaderSource(kernel: kernel)
        }
        
        _program = try Program.create(fragmentSource: fragmentSrc)
    }
    
    override func setUniformAttributs(context ctx: Context) {
        super.setUniformAttributs(context: ctx)
        
        let texelWidth = 1 / GLfloat(ctx.inputWidth)
        let texelHeight = 1 / GLfloat(ctx.inputHeight)
        _program.setUniform(name: kXOffset, value: texelWidth)
        _program.setUniform(name: kYOffset, value: texelHeight)
    }
    
    private func buildKernel(radius: Int, sigma: Double) -> [Double] {
        let kernelSize = Int(pow(Double(radius * 2 + 1), 2.0))
        let center = radius * (2 * radius + 1) + radius
        
        var ret: [Double] = []
        var sumOfWeight: Double = 0
        
        let twoSigmaSquare = 2 * pow(sigma, 2)
        let constant = 1 / sqrt(twoSigmaSquare * M_PI)
        for i in 0 ..< kernelSize {
            let weight = constant * exp(-Double(abs(i - center)) / twoSigmaSquare)
            ret.append(weight)
            
            sumOfWeight += weight
        }
        
        // normalize
        sumOfWeight = 1.0 / sumOfWeight
        return ret.map { $0 * sumOfWeight }
    }
    
    private func buildFragmentShaderSource(kernel: [Double]) -> String {
        var src = "#version 300 es                     \n"
            + "precision highp float;                  \n"
            + "in vec2 fTextCoor;                      \n"
            + "uniform sampler2D firstInput;           \n"
            + "uniform highp float xOffset;            \n"
            + "uniform highp float yOffset;            \n"
            + "out vec4 color;                         \n"
            + "void main() {                           \n"
            + "    vec4 acc = vec4(0.0);               \n"
            + "    vec4 tmp = texture(firstInput, fTextCoor); \n"
        
        for row in 0 ... 2 * _radius {
            for col in 0 ... 2 * _radius {
                let weight = kernel[row * (_radius * 2 + 1) + col]
                src += "acc += texture(firstInput, vec2(fTextCoor.s + xOffset * \(row - _radius).0, fTextCoor.t + yOffset * \(col - _radius).0)) * \(weight); \n"
            }
        }
        
        src += "float threshold = 0.2126 * acc.r + 0.7152 * acc.g + 0.0722 * acc.b;     \n"
        src += "float brightness = 0.2126 * tmp.r + 0.7152 * tmp.g + 0.0722 * tmp.b;    \n"
        
        switch _type {
        case .binary:
            src += "brightness = brightness < threshold ? 0.0 : \(_max);           \n"
            
        case .binary_inverse:
            src += "brightness = brightness < threshold ? \(_max) : 0.0;           \n"
            
        case .truncate:
            src += "brightness = brightness < threshold ? brightness : threshold;   \n"
            
        case .to_zero:
            src += "brightness = brightness < threshold ? 0.0 : brightness;         \n"
            
        case .to_zero_inverse:
            src += "brightness = brightness < threshold ? brightness : 0.0;         \n"
            break
        }
        
        src += "vec3 rgb = clamp(vec3(brightness, brightness, brightness), vec3(0.0), vec3(1.0));   \n"
        src += "color = vec4(rgb, tmp.a);                   \n"
        src += "}                                           \n"

        return src
    }
}
