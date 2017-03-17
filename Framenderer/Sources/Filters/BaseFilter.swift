//
//  BaseFilter.swift
//  Framenderer
//
//  Created by tqtifnypmb on 08/12/2016.
//  Copyright © 2016 tqitfnypmb. All rights reserved.
//

import Foundation
import OpenGLES.ES3.gl
import OpenGLES.ES3.glext
import CoreMedia
import AVFoundation

open class BaseFilter: Filter {
    var _program: Program!
    
    public var name: String {
        fatalError("Called Virtual Function")
    }
    
    public init() {}
    
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
    
    deinit {
        if _program != nil {
            ProgramObjectsCacher.shared.release(program: _program)
            _program = nil
        }
    }
    
    func feedDataAndDraw(context ctx: Context, program: Program) throws {
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
        
        try ctx.activateOutput()
        ctx.activateInput()
        glClearColor(0.0, 0.0, 0.0, 1.0);
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT));
        glDrawArrays(GLenum(GL_TRIANGLE_STRIP), 0, 4)
        
        glDeleteBuffers(1, &vbo)
    }
    
    public func apply(context ctx: Context) throws {
        do {
            ctx.toggleInputOutputIfNeeded()
            
            if _program == nil {
                try buildProgram()
                bindAttributes(context: ctx)
                try _program.link()
                ctx.setCurrent(program: _program)
                setUniformAttributs(context: ctx)
            } else {
                ctx.setCurrent(program: _program)
            }
            
            let outputFrameBuffer = try TextureOutputFrameBuffer(width: ctx.inputWidth, height: ctx.inputHeight, bitmapInfo: ctx.inputBitmapInfo, format: ctx.inputFormat)
            ctx.setOutput(output: outputFrameBuffer)
            try feedDataAndDraw(context: ctx, program: _program)
        } catch {
            throw FilterError.filterError(name: self.name, error: error.localizedDescription)
        }
    }
    
    public func applyToFrame(context ctx: Context, inputFrameBuffer: InputFrameBuffer, presentationTimeStamp time: CMTime, next: @escaping (Context, InputFrameBuffer) throws -> Void) throws {
        ctx.setAsCurrent()
        
        ctx.setInput(input: inputFrameBuffer)
        
        try apply(context: ctx)
        
        let input = ctx.outputFrameBuffer!.convertToInput(bitmapInfo: inputFrameBuffer.bitmapInfo)
        try next(ctx, input)
    }
    
    public func applyToAudio(context: Context, sampleBuffer: CMSampleBuffer, next: @escaping (Context, CMSampleBuffer) throws -> Void) throws {
        try next(context, sampleBuffer)
    }
}
