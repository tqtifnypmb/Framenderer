//
//  CameraPreviewView.swift
//  SwiftyImage
//
//  Created by tqtifnypmb on 04/01/2017.
//  Copyright © 2017 tqitfnypmb. All rights reserved.
//

import UIKit
import CoreMedia
import OpenGLES.ES3.gl
import OpenGLES.ES3.glext

open class CameraPreviewView: UIView, PreviewView {
    
    var _program: Program!
    
    override open class var layerClass: AnyClass {
        return CAEAGLLayer.self
    }
    
    var name: String {
        return "CameraPreviewView"
    }
    
    deinit {
        if _program != nil {
            ProgramObjectsCacher.shared.release(program: _program)
            _program = nil
        }
    }
    
    func apply(context ctx: Context) throws {
        fatalError()
    }
    
    func bindAttributes(context: Context) {
        let attr = [kVertexPositionAttribute, kTextureCoorAttribute]
        _program.bind(attributes: attr)
    }
    
    func setUniformAttributs(context: Context) {
        _program.setUniform(name: kFirstInputSampler, value: GLint(0))
    }
    
    func buildProgram() throws {
        _program = try Program.create(vertexSourcePath: "PassthroughVertexShader", fragmentSourcePath: "SingleInputFragmentShader")
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
        
        ctx.activateInput()
        glClearColor(0.0, 0.0, 0.0, 1.0);
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT));
        glDrawArrays(GLenum(GL_TRIANGLE_STRIP), 0, 4)
        
        glDeleteBuffers(1, &vbo)
    }
    
    func applyToFrame(context ctx: Context, inputFrameBuffer: InputFrameBuffer, time: CMTime, next: @escaping (Context, InputFrameBuffer) throws -> Void) throws {
        ctx.setAsCurrent()
        
        if _program == nil {
            try buildProgram()
            bindAttributes(context: ctx)
            try _program.link()
            ctx.setCurrent(program: _program)
            setUniformAttributs(context: ctx)
        } else {
            ctx.setCurrent(program: _program)
        }
        
        ctx.setInput(input: inputFrameBuffer)
        
        let layer = self.layer as! CAEAGLLayer
        let outputFrameBuffer = EAGLOutputFrameBuffer(eaglLayer: layer)
        try ctx.setOutput(output: outputFrameBuffer)

        try feedDataAndDraw(context: ctx, program: _program)
        outputFrameBuffer.present()
        
        let dumpInput = TextureInputFrameBuffer(texture: 0, width: 0, height: 0, bitmapInfo: CGBitmapInfo(rawValue: 0))
        try next(ctx, dumpInput)
    }
}
