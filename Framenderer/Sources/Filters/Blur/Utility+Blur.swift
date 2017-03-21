//
//  Utility+Blur.swift
//  Framenderer
//
//  Created by tqtifnypmb on 20/03/2017.
//  Copyright © 2017 tqtifnypmb. All rights reserved.
//

import Foundation

func buildTwoPassGaussianKernel(radius: Int, sigma: Double) -> [Double] {
    var ret: [Double] = []
    var sumOfWeight: Double = 0
    
    let twoSigmaSquare = 2 * pow(sigma, 2)
    let constant = 1 / sqrt(twoSigmaSquare * M_PI)
    for i in 0 ..< radius + 1 {
        let weight = constant * exp(-Double(i) / twoSigmaSquare)
        ret.append(weight)
        
        sumOfWeight += i == 0 ? weight : 2 * weight
    }
    
    // normalize
    sumOfWeight = 1.0 / sumOfWeight
    return ret.map { $0 * sumOfWeight }
}

func buildGaussianFragmentShaderSource(radius: Int, kernel: [Double]) -> String {
    let kernelSize = radius * 2 + 1
    
    var src = "#version 300 es                     \n"
        + "precision highp float;                  \n"
        + "in highp vec2 fTextCoor[\(kernelSize)]; \n"
        + "uniform sampler2D firstInput;           \n"
        + "out vec4 color;                         \n"
        + "void main() {                           \n"
        + "    vec4 acc = vec4(0.0);               \n"
    
    // Note: Presume that the passed in fTextCoor is
    //       in order : [center, center - 1, center + 1, center - 2, center + 2, ...]
    for i in 0 ..< kernelSize {
        let distance = i % 2 == 0 ? (i / 2) : (i / 2 + 1)
        let weight = kernel[distance]
        src += "acc += texture(firstInput, fTextCoor[\(i)]) * \(weight); \n"
    }
    
    src += "color = acc;                               \n"
    src += "}                                          \n"
    return src
}

func buildGaussianKernel(radius: Int, sigma: Double) -> [Double] {
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
