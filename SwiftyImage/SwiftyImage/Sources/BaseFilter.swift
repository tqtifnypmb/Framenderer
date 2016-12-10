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

let kVertexShader = "#version 300 es                 "
                  + "in vec4 vPosition;              "
                  + "in vec2 vTextCoor;              "
                  + "out vec2 fTextCoor;             "
                  + "void main() {                   "
                  + "   gl_Position = vPosition;     "
                  + "   fTextCoor = vTextCoor;       "
                  + "}                               "

let kFragmentShader = "#version 300 es               "
                    + "precision mediump float;      "
                    + "in vec2 fTextCoor;            "
                    + "uniform sampler2D fSampler;   "
                    + "out vec4 color;               "
                    + "void main() {                 "
                    + "   color = texture(fSampler, fTextCoor);"
                    + "}                             "
let kVertices: [GLfloat] = [
                            -1.0, -1.0,
                            -1.0,  1.0,
                             1.0, -1.0,
                             1.0,  1.0,
                           ]

class BaseFilter: Filter {
    var _program: Program!
    
    func bindAttributes() {
        let attr = ["vPosition", "vTextCoor"]
        _program.bind(attributes: attr)
    }
    
    func apply(context ctx: Context) throws {
        ctx.toggleInputOutputIfNeeded()
        
        _program = try Program.create(vertexSource: kVertexShader, fragmentSource: kFragmentShader)
        bindAttributes()
        try _program.link()
        ctx.setCurrent(program: _program)
        
        let outputFrameBuffer = FrameBuffer(width: ctx.inputWidth, height: ctx.inputHeight, bitmapInfo: ctx.inputBitmapInfo)
        ctx.setOutput(output: outputFrameBuffer)
        
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
    
        _program.setUniform(name: "fSampler", value: 0)
        
        ctx.activateInput()
        glClearColor(0.0, 0.0, 0.0, 1.0);
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT));
        glDrawArrays(GLenum(GL_TRIANGLE_STRIP), 0, 4)
        
        glDeleteBuffers(1, &vbo)
        _program = nil
    }
}
