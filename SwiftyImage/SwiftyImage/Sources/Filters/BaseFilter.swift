//
//  BaseFilter.swift
//  SwiftyImage
//
//  Created by tqtifnypmb on 08/12/2016.
//  Copyright © 2016 tqitfnypmb. All rights reserved.
//

import Foundation
import OpenGLES.ES3.gl
import OpenGLES.ES3.glext
import CoreMedia

public class BaseFilter: Filter {
    weak var _program: Program!
    
    func bindAttributes(context: Context) {
        let attr = [kVertexPositionAttribute, kTextureCoorAttribute]
        _program.bind(attributes: attr)
    }
    
    func setUniformAttributs(context: Context) {
        _program.setUniform(name: kFirstInputSampler, value: GLint(0))
    }
    
    func buildProgram() throws {
        fatalError("Called Virtual Function")
    }
    
    func feedDataAndDraw(context ctx: Context, program: Program) {
        var vbo: GLuint = 0
        glGenBuffers(1, &vbo)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), vbo)
        
        var attributes = kVertices
        attributes.append(contentsOf: ctx.textCoor)
        attributes.withUnsafeBytes { bytes in
            glBufferData(GLenum(GL_ARRAY_BUFFER), bytes.count, bytes.baseAddress, GLenum(GL_STATIC_DRAW))
        }
        glVertexAttribPointer(program.location(ofAttribute: kVertexPositionAttribute), 2, GLenum(GL_FLOAT), GLboolean(GL_FALSE), 0, nil)
        glEnableVertexAttribArray(program.location(ofAttribute: kVertexPositionAttribute))
        
        kVertices.withUnsafeBytes { bytes in
            let offset = UnsafeRawPointer(bitPattern: bytes.count)
            glVertexAttribPointer(program.location(ofAttribute: kTextureCoorAttribute), 2, GLenum(GL_FLOAT), GLboolean(GL_FALSE), 0, offset)
            glEnableVertexAttribArray(program.location(ofAttribute: kTextureCoorAttribute))
        }
        
        let outputFrameBuffer = FrameBuffer(width: ctx.inputWidth, height: ctx.inputHeight, bitmapInfo: ctx.inputBitmapInfo)
        ctx.setOutput(output: outputFrameBuffer)
        ctx.activateInput()
        glClearColor(0.0, 0.0, 0.0, 1.0);
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT));
        glDrawArrays(GLenum(GL_TRIANGLE_STRIP), 0, 4)
        
        glDeleteBuffers(1, &vbo)
    }
    
    func apply(context ctx: Context) throws {
        ctx.toggleInputOutputIfNeeded()
        
        try buildProgram()
        bindAttributes(context: ctx)
        try _program.link()
        ctx.setCurrent(program: _program)
        setUniformAttributs(context: ctx)
        
        feedDataAndDraw(context: ctx, program: _program)
        
        ProgramObjectsCacher.shared.release(program: _program)
        _program = nil
    }
    
    func applyToFrame(context: Context, time: CMTime, finishBlock: (Context) throws -> Void) throws {
        
    }
}
