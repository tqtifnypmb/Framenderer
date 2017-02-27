//
//  TwoPassFilter.swift
//  SwiftyImage
//
//  Created by tqtifnypmb on 11/12/2016.
//  Copyright © 2016 tqitfnypmb. All rights reserved.
//

import Foundation
import OpenGLES.ES3.gl
import OpenGLES.ES3.glext

open class TwoPassFilter: BaseFilter {
    var _program2: Program!
    var _isProgram2Setup = false
    
    func bindAttributes2(context: Context) {
        let attr = [kVertexPositionAttribute, kTextureCoorAttribute]
        _program2.bind(attributes: attr)
    }
    
    func setUniformAttributs2(context ctx: Context) {
         _program2.setUniform(name: kFirstInputSampler, value: GLint(1))
        
        let texelHeight = 1 / GLfloat(ctx.inputHeight)
        _program2.setUniform(name: kTexelWidth, value: GLfloat(0))
        _program2.setUniform(name: kTexelHeight, value: texelHeight)
    }
    
    deinit {
        if _program2 != nil {
            ProgramObjectsCacher.shared.release(program: _program2)
            _program2 = nil
        }
    }
    
    override func setUniformAttributs(context ctx: Context) {
        super.setUniformAttributs(context: ctx)
        
        let texelWidth = 1 / GLfloat(ctx.inputWidth)
        _program.setUniform(name: kTexelWidth, value: texelWidth)
        _program.setUniform(name: kTexelHeight, value: GLfloat(0))
    }

    override public func apply(context ctx: Context) throws {
        try super.apply(context: ctx)
        
        do {
            glActiveTexture(GLenum(GL_TEXTURE1))
            ctx.toggleInputOutputIfNeeded()
            
            if !_isProgram2Setup {
                _isProgram2Setup = true
                
                bindAttributes2(context: ctx)
                try _program2.link()
                ctx.setCurrent(program: _program2)
                setUniformAttributs2(context: ctx)
            } else {
                ctx.setCurrent(program: _program2)
            }
            
            try feedDataAndDraw(context: ctx, program: _program2)
        } catch {
            throw FilterError.filterError(name: self.name, error: error.localizedDescription)
        }
    }
}

func buildSeparableKernelVertexSource(radius: Int) -> String {
    let kernelSize = radius * 2 + 1
    
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
    
    for i in 0 ..< radius {
        src += "textCoor[\(i * 2 + 1)] = vTextCoor - \(i + 1).0 * step; \n"
        src += "textCoor[\(i * 2 + 2)] = vTextCoor + \(i + 1).0 * step; \n"
    }
    src += "fTextCoor = textCoor;                      \n"
    src += "}                                          \n"
    return src
}