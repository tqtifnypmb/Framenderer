//
//  EAGLOuputFrameBuffer.swift
//  SwiftyImage
//
//  Created by tqtifnypmb on 04/01/2017.
//  Copyright © 2017 tqitfnypmb. All rights reserved.
//

import Foundation
import QuartzCore

class EAGLOutputFrameBuffer: OutputFrameBuffer {
    private var _fbo: GLuint = 0
    private var _rbo: GLuint = 0
    private var _width: GLsizei = 0
    private var _height:GLsizei = 0
    private let _layer: CAEAGLLayer
    
    init(eaglLayer layer: CAEAGLLayer) {
        _layer = layer
        _layer.isOpaque = true
        _layer.drawableProperties = [kEAGLDrawablePropertyRetainedBacking: false, kEAGLDrawablePropertyColorFormat: kEAGLColorFormatRGBA8]
    }
    
    deinit {
        if _fbo != 0 {
            glDeleteFramebuffers(1, &_fbo)
            _fbo = 0
        }
        
        if _rbo != 0 {
            glDeleteRenderbuffers(1, &_rbo)
            _rbo = 0
        }
    }
    
    func useAsOutput() {
        if (_fbo == 0) {
            self.createRenderBuffer()
        }
        
        glViewport(0, 0, _width, _height)
    }
    
    private func createRenderBuffer() {
        glGenFramebuffers(1, &_fbo)
        glBindFramebuffer(GLenum(GL_FRAMEBUFFER), _fbo)
        
        // set up color renderbuffer
        
        glGenRenderbuffers(1, &_rbo)
        glBindRenderbuffer(GLenum(GL_RENDERBUFFER), _rbo)
        guard EAGLContext.current().renderbufferStorage(Int(GL_RENDERBUFFER), from: _layer) else {
            fatalError("Create renderbuffer failed")
        }
        
        glFramebufferRenderbuffer(GLenum(GL_FRAMEBUFFER),
                                  GLenum(GL_COLOR_ATTACHMENT0),
                                  GLenum(GL_RENDERBUFFER),
                                  _rbo)
        
        glGetRenderbufferParameteriv(GLenum(GL_RENDERBUFFER),
                                     GLenum(GL_RENDERBUFFER_WIDTH),
                                     &_width)
        
        glGetRenderbufferParameteriv(GLenum(GL_RENDERBUFFER),
                                     GLenum(GL_RENDERBUFFER_HEIGHT),
                                     &_height)
        
        validate()
    }
    
    private func validate() {
        let status = glCheckFramebufferStatus(GLenum(GL_FRAMEBUFFER))
        if status != GLenum(GL_FRAMEBUFFER_COMPLETE) {
            fatalError("\(status)")
        }
    }
    
    func present() {
        EAGLContext.current().presentRenderbuffer(Int(GL_RENDERBUFFER))
    }
    
    func convertToImage() -> CGImage? {
        return nil
    }
    
    func convertToInput(bitmapInfo: CGBitmapInfo) -> InputFrameBuffer {
        fatalError()
    }
}
