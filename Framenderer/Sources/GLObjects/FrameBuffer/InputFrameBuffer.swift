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
    //func retrieveRawData() -> [GLubyte]
    
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

func readTextureRawData(texture: GLuint, size: Int) -> [GLubyte] {
    glBindTexture(GLenum(GL_TEXTURE_2D), texture)
    
    var buffer = [GLubyte](repeating: 0, count: size)
    buffer.withUnsafeMutableBytes { ptr in
        //glGetTexImage
    }
    
    return buffer
}
