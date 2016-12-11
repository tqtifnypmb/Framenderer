//
//  BaseFilter.swift
//  SwiftyImage
//
//  Created by tqtifnypmb on 08/12/2016.
//  Copyright © 2016 tqitfnypmb. All rights reserved.
//

import UIKit
import OpenGLES.ES3.gl
import OpenGLES.ES3.glext

let kVertices: [GLfloat] = [
                            -1.0, -1.0,
                            -1.0,  1.0,
                             1.0, -1.0,
                             1.0,  1.0,
                           ]

class BaseFilter: Filter {
    var _program: Program!
    
    func bindAttributes(context: Context) {
        let attr = ["vPosition", "vTextCoor"]
        _program.bind(attributes: attr)
    }
    
    func setUniformAttributs(context: Context) {
        _program.setUniform(name: "firstInput", value: GLint(0))
    }
    
    func buildProgram() throws {
        _program = try Program.create(vertexSourcePath: "PassthroughVertexShader", fragmentSourcePath: "SingleInputFragmentShader")
    }
    
    func apply(context ctx: Context) throws {
        ctx.toggleInputOutputIfNeeded()
        
        try buildProgram()
        bindAttributes(context: ctx)
        try _program.link()
        ctx.setCurrent(program: _program)
        setUniformAttributs(context: ctx)
        
        var vbo: GLuint = 0
        glGenBuffers(1, &vbo)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), vbo)
        
        var attributes = kVertices
        attributes.append(contentsOf: ctx.textCoor)
        attributes.withUnsafeBytes { bytes in
            glBufferData(GLenum(GL_ARRAY_BUFFER), bytes.count, bytes.baseAddress, GLenum(GL_STATIC_DRAW))
        }
        glVertexAttribPointer(_program.location(ofAttribute: "vPosition"), 2, GLenum(GL_FLOAT), GLboolean(GL_FALSE), 0, nil)
        glEnableVertexAttribArray(_program.location(ofAttribute: "vPosition"))
        
        kVertices.withUnsafeBytes { bytes in
            let offset = UnsafeRawPointer(bitPattern: bytes.count)
            glVertexAttribPointer(_program.location(ofAttribute: "vTextCoor"), 2, GLenum(GL_FLOAT), GLboolean(GL_FALSE), 0, offset)
            glEnableVertexAttribArray(_program.location(ofAttribute: "vTextCoor"))
        }
        
        let outputFrameBuffer = FrameBuffer(width: ctx.inputWidth, height: ctx.inputHeight, bitmapInfo: ctx.inputBitmapInfo)
        ctx.setOutput(output: outputFrameBuffer)
        ctx.activateInput()
        glClearColor(0.0, 0.0, 0.0, 1.0);
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT));
        glDrawArrays(GLenum(GL_TRIANGLE_STRIP), 0, 4)
        
        glDeleteBuffers(1, &vbo)
        _program = nil
    }
}
