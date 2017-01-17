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
    
    private let _isFont: Bool
    
    private enum Rotation {
        case none
        case ccw90
        case ccw180
        case ccw270
    }
    
    /// Create a input framebuffer object using samplebuffer as content
    init(sampleBuffer: CMSampleBuffer, isFont: Bool) throws {
        _isFont = isFont
        
        if let cv = CMSampleBufferGetImageBuffer(sampleBuffer) {
            CVPixelBufferLockBaseAddress(cv, .readOnly)
            
            let bpr = CVPixelBufferGetBytesPerRow(cv)
            let width = bpr / 4
            let height = CVPixelBufferGetHeight(cv)
            
            glGenTextures(1, &_texture)
            glBindTexture(GLenum(GL_TEXTURE_2D), _texture)
            glTexImage2D(GLenum(GL_TEXTURE_2D),
                         0,
                         GL_RGBA,
                         GLsizei(width),
                         GLsizei(height),
                         0,
                         GLenum(GL_BGRA),
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
        
        switch UIDevice.current.orientation {
        case .landscapeRight:
            rotation = _isFont ? .ccw180 : .none
            
        case .portrait:
            rotation = .ccw90
            
        case .landscapeLeft:
            rotation = _isFont ? .none : .ccw180
            
        case .portraitUpsideDown:
            rotation = _isFont ? .none : .ccw270
            
        default:
            rotation = .none
        }
        
        switch rotation {
        case .none:
            return [
                0.0, 0.0,
                0.0, 1.0,
                1.0, 0.0,
                1.0, 1.0
            ]
            
        case .ccw90:
            return [
                1.0, 0.0,
                0.0, 0.0,
                1.0, 1.0,
                0.0, 1.0
            ]
            
        case .ccw180:
            return [
                1.0, 1.0,
                1.0, 0.0,
                0.0, 1.0,
                0.0, 0.0
            ]
            
        case .ccw270:
            return [
                0.0, 1.0,
                1.0, 1.0,
                0.0, 0.0,
                1.0, 0.0
            ]
        }
    }
    
    deinit {
        if _texture != 0 {
            _texture = 0
            glDeleteTextures(1, &_texture)
        }
    }
}
