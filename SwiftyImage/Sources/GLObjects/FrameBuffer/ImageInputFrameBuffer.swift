//
//  ImageInputFrameBuffer.swift
//  SwiftyImage
//
//  Created by tqtifnypmb on 17/01/2017.
//  Copyright © 2017 tqitfnypmb. All rights reserved.
//

import GLKit
import OpenGLES.ES3.gl
import OpenGLES.ES3.glext

class ImageInputFrameBuffer: InputFrameBuffer {

    private var _texture: GLuint = 0
    private let _textureWidth: GLsizei
    private let _textureHeight: GLsizei
    
    /// Create a input framebuffer object using `texture` as content
    /// Note: Texture format is RGB32
    init(image: CGImage) throws {
        
        let textureInfo = try GLKTextureLoader.texture(with: image, options: [GLKTextureLoaderOriginBottomLeft : false])
        _texture = textureInfo.name
        _textureWidth = GLsizei(textureInfo.width)
        _textureHeight = GLsizei(textureInfo.height)
        
        assert(textureInfo.target == GLenum(GL_TEXTURE_2D))
        
        switch textureInfo.alphaState {
        case .premultiplied:
            print("Prem")
            
        case .nonPremultiplied:
            print("non Prem")
            
        default:
            print("None")
        }
        
        switch image.alphaInfo {
        case .premultipliedLast:
            print("Prem")
            
        case .premultipliedFirst:
            print("non Prem")
            
        default:
            print("None")
        }
    }
    
    func useAsInput() {
        glBindTexture(GLenum(GL_TEXTURE_2D), _texture)
    }
    
    var bitmapInfo: CGBitmapInfo {
        return CGBitmapInfo(rawValue: CGImageAlphaInfo.none.rawValue)
    }
    
    var width: GLsizei {
        return _textureWidth
    }

    var height: GLsizei {
        return _textureHeight
    }

    var textCoor: [GLfloat] {
        return [
                  0.0, 0.0,
                  0.0, 1.0,
                  1.0, 0.0,
                  1.0, 1.0
               ]
    }
    
    deinit {
        if _texture != 0 {
            glDeleteTextures(1, &_texture)
            _texture = 0
        }
    }
}
