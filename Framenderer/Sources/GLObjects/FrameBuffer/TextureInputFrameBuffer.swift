//
//  TextureInputFrameBuffer.swift
//  Framenderer
//
//  Created by tqtifnypmb on 17/01/2017.
//  Copyright © 2017 tqitfnypmb. All rights reserved.
//

import Foundation
import GLKit
import OpenGLES.ES3.gl
import OpenGLES.ES3.glext

class TextureInputFrameBuffer: InputFrameBuffer {    
    private let _texture: GLuint
    private let _textureWidth: GLsizei
    private let _textureHeight: GLsizei
    private var _bitmapInfo: CGBitmapInfo!
    private var _flipVertically = false
    
    var originalOutputFrameBuffer: OutputFrameBuffer!
    
    init(texture: GLuint, width: GLsizei, height: GLsizei, bitmapInfo: CGBitmapInfo) {
        _texture = texture
        _textureWidth = width
        _textureHeight = height
        _bitmapInfo = bitmapInfo
    }
    
    func useAsInput() {
        glBindTexture(GLenum(GL_TEXTURE_2D), _texture)
    }
    
    func textCoorFlipVertically(flip: Bool) {
        _flipVertically = flip
    }
    
    var bitmapInfo: CGBitmapInfo {
        return _bitmapInfo
    }
    
    var width: GLsizei {
        return _textureWidth
    }
    
    var height: GLsizei {
        return _textureHeight
    }
    
    var textCoor: [GLfloat] {
        let coor: [GLfloat] = [
            0.0, 0.0,
            0.0, 1.0,
            1.0, 0.0,
            1.0, 1.0
        ]
        
        if _flipVertically {
            return flipTextCoorVertically(textCoor: coor)
        } else {
            return coor
        }
    }
}
