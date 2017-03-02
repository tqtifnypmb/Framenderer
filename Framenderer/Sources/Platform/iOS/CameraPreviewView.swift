//
//  CameraPreviewView.swift
//  Framenderer
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

    public var contentScaleMode: ContentScaleMode = .scaleToFill
    
    public var name: String {
        return "CameraPreviewView"
    }
    
    deinit {
        if _program != nil {
            ProgramObjectsCacher.shared.release(program: _program)
            _program = nil
        }
    }
    
    public func apply(context ctx: Context) throws {
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
        _program = try Program.create(vertexSourcePath: "PassthroughVertexShader", fragmentSourcePath: "PassthroughFragmentShader")
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
    
    public func applyToFrame(context ctx: Context, inputFrameBuffer: InputFrameBuffer, presentationTimeStamp time: CMTime, next: @escaping (Context, InputFrameBuffer) throws -> Void) throws {
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
        
        inputFrameBuffer.textCoorFlipVertically(flip: true)
        ctx.setInput(input: inputFrameBuffer)
        
        let layer = self.layer as! CAEAGLLayer
        let outputFrameBuffer = EAGLOutputFrameBuffer(eaglLayer: layer)
        ctx.setOutput(output: outputFrameBuffer)

        try feedDataAndDraw(context: ctx, program: _program)
        outputFrameBuffer.present()
        
        inputFrameBuffer.textCoorFlipVertically(flip: false)
        // Act like a passthrough filter
        try next(ctx, inputFrameBuffer)
    }
}
