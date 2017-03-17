//
//  YUVInputFrameBuffer.swift
//  Framenderer
//
//  Created by tqtifnypmb on 17/03/2017.
//  Copyright © 2017 tqtifnypmb. All rights reserved.
//

import Foundation
import CoreMedia
import OpenGLES.ES3.gl
import OpenGLES.ES3.glext

class YUVInputFrameBuffer: InputFrameBuffer {
    
    private var _flipVertically = false
    private var _texture: GLuint
    private let _isY: Bool
    init(sampleBuffer sm: CMSampleBuffer, planarIndex: Int) throws {
        _isY = planarIndex == 0
        
        if let pb = CMSampleBufferGetImageBuffer(sm) {
            CVPixelBufferLockBaseAddress(pb, .readOnly)
            var texture: CVOpenGLESTexture!
            if _isY {
                let width = CVPixelBufferGetWidthOfPlane(pb, 0)
                let height = CVPixelBufferGetHeightOfPlane(pb, 0)
                texture = try TextureCacher.shared.createTexture(fromPixelBuffer: pb, target: GLenum(GL_TEXTURE_2D), internalFormat: GL_LUMINANCE, format: GLenum(GL_LUMINANCE), width: GLsizei(width), height: GLsizei(height), planarIndex: planarIndex)
            } else {
                let width = CVPixelBufferGetWidthOfPlane(pb, 1)
                let height = CVPixelBufferGetHeightOfPlane(pb, 1)
                texture = try TextureCacher.shared.createTexture(fromPixelBuffer: pb, target: GLenum(GL_TEXTURE_2D), internalFormat: GL_LUMINANCE, format: GLenum(GL_LUMINANCE_ALPHA), width: GLsizei(width) / 2, height: GLsizei(height) / 2, planarIndex: planarIndex)
            }
            CVPixelBufferUnlockBaseAddress(pb, .readOnly)
            
            _texture = CVOpenGLESTextureGetName(texture)
            glBindTexture(GLenum(GL_TEXTURE_2D), _texture)
            glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MAG_FILTER), GL_LINEAR)
            glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MIN_FILTER), GL_LINEAR)
            glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_S), GL_CLAMP_TO_EDGE)
            glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_T), GL_CLAMP_TO_EDGE)
            glBindTexture(GLenum(GL_TEXTURE_2D), 0)
        } else {
            throw DataError.sample(errorDesc: "CMSampleBuffer doesn't contain image data")
        }
    }
    
    func useAsInput() {
        glBindTexture(GLenum(GL_TEXTURE_2D), _texture)
    }
    
    func textCoorFlipVertically(flip: Bool) {
        _flipVertically = flip
    }
    
    var width: GLsizei {
        return 0
    }
    
    var height: GLsizei {
        return 0
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
    
    var format: GLenum {
        return _isY ? GLenum(GL_LUMINANCE) : GLenum(GL_LUMINANCE_ALPHA)
    }
}
