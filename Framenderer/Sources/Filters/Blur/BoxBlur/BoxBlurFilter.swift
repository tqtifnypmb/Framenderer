//
//  BoxBlurFilter.swift
//  Framenderer
//
//  Created by tqtifnypmb on 11/12/2016.
//  Copyright © 2016 tqitfnypmb. All rights reserved.
//

import Foundation
import OpenGLES.ES3.gl
import OpenGLES.ES3.glext

public class BoxBlurFilter: TwoPassFilter {
    
    private let _radius: Int
    private var _vertexShaderSrc: String!
    private var _fragmentShaderSrc: String!
    
    override public var name: String {
        return "BoxBlurFilter"
    }
    
    /**
     init a [Box blur](https://en.wikipedia.org/wiki/Box_blur) filter
     
     - parameter radius: specifies the distance from the center of the blur effect.
     */
    init(radius: Int = 4) {
        precondition(radius >= 1)
        
        _radius = radius
        super.init()
    }
    
    private func buildFragmentSource() -> String {
        let validRadius = min(_radius, (Limits.max_varying_components - 1) / 2)
        let kernelSize = validRadius * 2 + 1
        let weight = 1.0 / GLfloat(kernelSize)
        
        var src = "#version 300 es                         \n"
                + "precision highp float;                  \n"
                + "in highp vec2 fTextCoor[\(kernelSize)]; \n"
                + "uniform sampler2D firstInput;           \n"
                + "out vec4 color;                         \n"
                + "void main() {                           \n"
                + "    vec4 acc = vec4(0.0);               \n"
        
        for i in 0 ..< kernelSize {
            src += "acc += texture(firstInput, fTextCoor[\(i)]) * \(weight); \n"
        }
        
        src += "color = acc;                               \n"
        src += "}                                          \n"
        return src
    }
    
    override func buildProgram() throws {
        if _vertexShaderSrc == nil {
            let validRadius = min(_radius, (Limits.max_varying_components - 1) / 2)
            _vertexShaderSrc = buildSeparableKernelVertexSource(radius: validRadius)
            _fragmentShaderSrc = buildFragmentSource()
        }
        
        _program = try Program.create(vertexSource: _vertexShaderSrc, fragmentSource: _fragmentShaderSrc)
        _program2 = try Program.create(vertexSource: _vertexShaderSrc, fragmentSource: _fragmentShaderSrc)
    }
}
