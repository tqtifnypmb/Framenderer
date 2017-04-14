//
//  InputFrameBuffer.swift
//  Framenderer
//
//  Created by tqtifnypmb on 04/01/2017.
//  Copyright © 2017 tqitfnypmb. All rights reserved.
//

import OpenGLES.ES3.gl
import OpenGLES.ES3.glext
import CoreGraphics
import CoreVideo

public protocol InputFrameBuffer {
    func useAsInput()
    func textCoorFlipVertically(flip: Bool)
    func retrieveRawData() -> [GLubyte]
    
    var width: GLsizei { get }
    var height: GLsizei { get }
    var textCoor: [GLfloat] { get }
    var format: GLenum { get }
}

enum Rotation {
    case none
    case ccw90
    case ccw180
    case ccw270
}

// Since glGetTexImage is not supported by OpenGL ES, We bind the texture to a framebuffer
// and read from that.
func readTextureRawData(texture: GLuint, width: GLsizei, height: GLsizei) -> [GLubyte] {
    var fbo: GLuint = 0
    glGenFramebuffers(1, &fbo)
    
    defer {
        glDeleteFramebuffers(1, &fbo)
    }
    
    glBindFramebuffer(GLenum(GL_FRAMEBUFFER), fbo)
    
    glBindTexture(GLenum(GL_TEXTURE_2D), texture)
    
    glFramebufferTexture2D(GLenum(GL_FRAMEBUFFER),
                           GLenum(GL_COLOR_ATTACHMENT0),
                           GLenum(GL_TEXTURE_2D),
                           texture,
                           0)
    glBindTexture(GLenum(GL_TEXTURE_2D), 0)
    
    let status = glCheckFramebufferStatus(GLenum(GL_FRAMEBUFFER))
    if status != GLenum(GL_FRAMEBUFFER_COMPLETE) {
        return []
    }
    
    glReadBuffer(GLenum(GL_COLOR_ATTACHMENT0))
    
    var rawImageData = [GLubyte](repeating: 0, count: Int(width * height * 4))
    rawImageData.withUnsafeMutableBytes { ptr in
        glReadPixels(0,
                     0,
                     width,
                     height,
                     GLenum(GL_RGBA),
                     GLenum(GL_UNSIGNED_BYTE),
                     ptr.baseAddress)
    }
    
    return rawImageData
}
