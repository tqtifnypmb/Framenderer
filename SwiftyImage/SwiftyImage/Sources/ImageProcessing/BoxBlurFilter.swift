//
//  BoxBlurFilter.swift
//  SwiftyImage
//
//  Created by tqtifnypmb on 11/12/2016.
//  Copyright © 2016 tqitfnypmb. All rights reserved.
//

import Foundation
import OpenGLES.ES3.gl
import OpenGLES.ES3.glext

class BoxBlurFilter: TwoPassFilter {
    
    private let _radius: Int
    private var _vertexShaderSrc: String!
    private var _fragmentShaderSrc: String!
    
    init(radius: Int = 4) {
        precondition(radius >= 1)
        _radius = radius
        super.init()
        
        _vertexShaderSrc = buildVertexSource()
        _fragmentShaderSrc = buildFragmentSource()
    }
    
    private func buildVertexSource() -> String {
        let kernelSize = _radius * 2 + 1
        
        var src = "#version 300 es                          "
                + "in vec4 vPosition;                       "
                + "in vec2 vTextCoor;                       "
                + "uniform highp float xOffset;             "
                + "uniform highp float yOffset;             "
                + "out highp vec2 fTextCoor[\(kernelSize)]; "
        
                + "void main() {                            "
                + "    gl_Position = vPosition;             "
                + "    vec2 step = vec2(xOffset, yOffset);  "
                + "    vec2 textCoor[\(kernelSize)];        "
        
        for i in 0 ..< _radius {
            src += "textCoor[\(i)] = vTextCoor - \(i + 1).0 * step; "
            src += "textCoor[\(i * 2)] = vTextCoor + \(i + 1).0 * step; "
        }
        src += "textCoor[\(kernelSize - 1)] = vTextCoor;    "
        src += "fTextCoor = textCoor;                       "
        src += "}"
        
        return src
    }
    
    private func buildFragmentSource() -> String {
        let kernelSize = _radius * 2 + 1
        let weight = 1.0 / GLfloat(kernelSize)
        
        var src = "#version 300 es                          "
                + "precision highp float;                   "
                + "in highp vec2 fTextCoor[\(kernelSize)];  "
                + "uniform sampler2D firstInput;            "
                + "out vec4 color;                          "
                + "void main() {                            "
                + "    vec4 acc = vec4(0.0);                "
        
        for i in 0 ..< kernelSize {
            src += "acc += texture(firstInput, fTextCoor[\(i)]) * \(weight);"
        }
        
        src += "color = acc;"
        src += "}"
        return src
    }
    
    override func setUniformAttributs2(context ctx: Context) {
        super.setUniformAttributs2(context: ctx)
        
        let texelHeight = 1 / GLfloat(ctx.inputHeight)
        _program2.setUniform(name: "xOffset", value: GLfloat(0))
        _program2.setUniform(name: "yOffset", value: texelHeight)
    }
    
    override func setUniformAttributs(context ctx: Context) {
        super.setUniformAttributs(context: ctx)
        
        let texelWidth = 1 / GLfloat(ctx.inputWidth)
        _program.setUniform(name: "xOffset", value: texelWidth)
        _program.setUniform(name: "yOffset", value: GLfloat(0))
    }
    
    override func buildProgram() throws {
        _program = try Program.create(vertexSource: _vertexShaderSrc, fragmentSource: _fragmentShaderSrc)
    }
    
    override func buildProgram2() throws {
        _program2 = try Program.create(vertexSource: _vertexShaderSrc, fragmentSource: _fragmentShaderSrc)
    }
}
