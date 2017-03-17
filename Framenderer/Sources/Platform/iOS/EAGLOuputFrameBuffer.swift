//
//  EAGLOuputFrameBuffer.swift
//  Framenderer
//
//  Created by tqtifnypmb on 04/01/2017.
//  Copyright © 2017 tqitfnypmb. All rights reserved.
//

import Foundation
import QuartzCore

class EAGLOutputFrameBuffer: OutputFrameBuffer {
    private var _frameBuffer: GLuint = 0
    private var _renderBuffer: GLuint = 0
    private var _width: GLsizei = 0
    private var _height:GLsizei = 0
    private let _eaglLayer: CAEAGLLayer
    
    init(eaglLayer layer: CAEAGLLayer) {
        _eaglLayer = layer
        layer.isOpaque = true
        layer.drawableProperties = [kEAGLDrawablePropertyRetainedBacking: false, kEAGLDrawablePropertyColorFormat: kEAGLColorFormatRGBA8]
    }
    
    deinit {
        if _frameBuffer != 0 {
            glDeleteFramebuffers(1, &_frameBuffer)
            _frameBuffer = 0
        }
        
        if _renderBuffer != 0 {
            EAGLContext.current().renderbufferStorage(Int(GL_RENDERBUFFER), from: nil)
            glDeleteRenderbuffers(1, &_renderBuffer)
            _renderBuffer = 0
        }
    }
    
    func useAsOutput() throws {
        precondition(_frameBuffer == 0)
        
        glGenFramebuffers(1, &_frameBuffer)
        glBindFramebuffer(GLenum(GL_FRAMEBUFFER), _frameBuffer)
        
        // set up color renderbuffer
        
        glGenRenderbuffers(1, &_renderBuffer)
        glBindRenderbuffer(GLenum(GL_RENDERBUFFER), _renderBuffer)
        guard EAGLContext.current().renderbufferStorage(Int(GL_RENDERBUFFER), from: _eaglLayer) else {
            fatalError("Create renderbuffer failed")
        }
        
        glFramebufferRenderbuffer(GLenum(GL_FRAMEBUFFER),
                                  GLenum(GL_COLOR_ATTACHMENT0),
                                  GLenum(GL_RENDERBUFFER),
                                  _renderBuffer)
        
        glGetRenderbufferParameteriv(GLenum(GL_RENDERBUFFER),
                                     GLenum(GL_RENDERBUFFER_WIDTH),
                                     &_width)
        
        glGetRenderbufferParameteriv(GLenum(GL_RENDERBUFFER),
                                     GLenum(GL_RENDERBUFFER_HEIGHT),
                                     &_height)
        
        try validate()
        
        glViewport(0, 0, _width, _height)
    }
    
    private func validate() throws {
        let status = glCheckFramebufferStatus(GLenum(GL_FRAMEBUFFER))
        if status != GLenum(GL_FRAMEBUFFER_COMPLETE) {
            throw GLError.invalidFramebuffer(status: status)
        }
    }
    
    func present() {
        EAGLContext.current().presentRenderbuffer(Int(GL_RENDERBUFFER))
    }
    
    func convertToImage() -> CGImage? {
        return nil
    }
    
    func convertToInput() -> InputFrameBuffer {
        fatalError()
    }
}
