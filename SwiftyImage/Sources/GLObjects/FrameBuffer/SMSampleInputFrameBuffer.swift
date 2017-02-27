//
//  SMSampleInputFrameBuffer.swift
//  SwiftyImage
//
//  Created by tqtifnypmb on 17/01/2017.
//  Copyright © 2017 tqitfnypmb. All rights reserved.
//

import Foundation
import GLKit
import OpenGLES.ES3.gl
import OpenGLES.ES3.glext
import CoreMedia

class SMSampleInputFrameBuffer: InputFrameBuffer {
    
    private var _texture: GLuint = 0
    private let _textureWidth: GLsizei
    private let _textureHeight: GLsizei
    private var _flipVertically = false
    private let _isFont: Bool
    
    /// Create a input framebuffer object using samplebuffer as content
    init(sampleBuffer: CMSampleBuffer, isFont: Bool) throws {
        _isFont = isFont
        
        if let cv = CMSampleBufferGetImageBuffer(sampleBuffer) {
            CVPixelBufferLockBaseAddress(cv, .readOnly)
            
            let bpr = CVPixelBufferGetBytesPerRow(cv)
            let width = bpr / 4
            let height = CVPixelBufferGetHeight(cv)
            
            let format = isSupportFastTexture() ? GLenum(GL_BGRA) : GLenum(GL_RGBA)
            glGenTextures(1, &_texture)
            glBindTexture(GLenum(GL_TEXTURE_2D), _texture)
            glTexImage2D(GLenum(GL_TEXTURE_2D),
                         0,
                         GL_RGBA,
                         GLsizei(width),
                         GLsizei(height),
                         0,
                         format,
                         GLenum(GL_UNSIGNED_BYTE),
                         CVPixelBufferGetBaseAddress(cv)!)
            
            CVPixelBufferUnlockBaseAddress(cv, .readOnly)
            
            _textureWidth = GLsizei(width)
            _textureHeight = GLsizei(height)
            
            glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MAG_FILTER), GL_LINEAR)
            glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MIN_FILTER), GL_LINEAR)
            glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_S), GL_CLAMP_TO_EDGE)
            glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_T), GL_CLAMP_TO_EDGE)
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
    
    var bitmapInfo: CGBitmapInfo {
        return [CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue), .byteOrder32Little]
    }
    
    var width: GLsizei {
        return _textureWidth
    }
    
    var height: GLsizei {
        return _textureHeight
    }
    
    var textCoor: [GLfloat] {        
        var rotation: Rotation = .none
        var flipHorzontally = false
        
        switch UIDevice.current.orientation {
        case .landscapeRight:
            rotation = _isFont ? .none : .ccw180
            
        case .portrait:
            rotation = .ccw90
           
        case .landscapeLeft:
            rotation = _isFont ? .ccw180 : .none
           
        case .portraitUpsideDown:
            rotation = _isFont ? .ccw90 : .ccw270
            flipHorzontally = true
            
        default:
            rotation = .none
        }
        
        let coor = textCoordinate(forRotation: rotation, flipHorizontally: flipHorzontally, flipVertically: false)
        
        if _flipVertically {
            return flipTextCoorVertically(textCoor: coor)
        } else {
            return coor
        }
    }
    
    deinit {
        if _texture != 0 {
            glDeleteTextures(1, &_texture)
            _texture = 0
        }
    }
}
