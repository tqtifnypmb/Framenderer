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
        
        _radius = radius//min(radius, 8)
        super.init()
        
        _vertexShaderSrc = buildVertexSource()
        _fragmentShaderSrc = buildFragmentSource()
    }
    
    private func buildVertexSource() -> String {
        let kernelSize = _radius * 2 + 1
        
        var src = "#version 300 es                         \n"
                + "in vec4 vPosition;                      \n"
                + "in vec2 vTextCoor;                      \n"
                + "uniform highp float texelWidth;         \n"
                + "uniform highp float texelHeight;        \n"
                + "out highp vec2 fTextCoor[\(kernelSize)];\n"
        
                + "void main() {                           \n"
                + "    gl_Position = vPosition;            \n"
                + "    vec2 step = vec2(texelWidth, texelHeight); \n"
                + "    vec2 textCoor[\(kernelSize)];       \n"
                + "    textCoor[0] = vTextCoor;            \n"
        
        for i in 0 ..< _radius {
            src += "textCoor[\(i * 2 + 1)] = vTextCoor - \(i + 1).0 * step;\n"
            src += "textCoor[\(i * 2 + 2)] = vTextCoor + \(i + 1).0 * step;\n"
        }
        src += "fTextCoor = textCoor;                      \n"
        src += "}                                          \n"
        return src
    }
    
    private func buildFragmentSource() -> String {
        let kernelSize = _radius * 2 + 1
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
    
    override func setUniformAttributs2(context ctx: Context) {
        super.setUniformAttributs2(context: ctx)
        
        let texelHeight = 1 / GLfloat(ctx.inputHeight)
        _program2.setUniform(name: "texelWidth", value: GLfloat(0))
        _program2.setUniform(name: "texelHeight", value: texelHeight)
    }
    
    override func setUniformAttributs(context ctx: Context) {
        super.setUniformAttributs(context: ctx)
        
        let texelWidth = 1 / GLfloat(ctx.inputWidth)
        _program.setUniform(name: "texelWidth", value: texelWidth)
        _program.setUniform(name: "texelHeight", value: GLfloat(0))
    }
    
    override func buildProgram() throws {
        _program = try Program.create(vertexSource: _vertexShaderSrc, fragmentSource: _fragmentShaderSrc)
    }
    
    override func buildProgram2() throws {
        _program2 = try Program.create(vertexSource: _vertexShaderSrc, fragmentSource: _fragmentShaderSrc)
    }
}
