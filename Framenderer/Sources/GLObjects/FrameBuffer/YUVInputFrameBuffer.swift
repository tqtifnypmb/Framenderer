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
    private let _width: GLsizei
    private let _height: GLsizei
    private let _isFont: Bool
        
    init(sampleBuffer sm: CMSampleBuffer, planarIndex: Int, isFrontCamera: Bool) throws {
        _isY = planarIndex == 0
        _isFont = isFrontCamera
        
        if let pb = CMSampleBufferGetImageBuffer(sm) {
            CVPixelBufferLockBaseAddress(pb, .readOnly)
            var texture: CVOpenGLESTexture!
            
            _width = GLsizei(CVPixelBufferGetWidthOfPlane(pb, planarIndex))
            _height = GLsizei(CVPixelBufferGetHeightOfPlane(pb, planarIndex))
            
            if _isY {
                texture = try TextureCacher.shared.createTexture(fromPixelBuffer: pb, target: GLenum(GL_TEXTURE_2D), internalFormat: GL_LUMINANCE, format: GLenum(GL_LUMINANCE), width: _width, height: _height, planarIndex: planarIndex)
            } else {
                texture = try TextureCacher.shared.createTexture(fromPixelBuffer: pb, target: GLenum(GL_TEXTURE_2D), internalFormat: GL_LUMINANCE_ALPHA, format: GLenum(GL_LUMINANCE_ALPHA), width: _width / 2, height: _height / 2, planarIndex: planarIndex)
            }
            CVPixelBufferUnlockBaseAddress(pb, .readOnly)
            
            _texture = CVOpenGLESTextureGetName(texture)
            glBindTexture(GLenum(GL_TEXTURE_2D), _texture)
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
    
    func retrieveRawData() -> [GLubyte] {
        return []
    }
    
    var width: GLsizei {
        precondition(_isY)
        return _width
    }
    
    var height: GLsizei {
        precondition(_isY)
        return _height
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
    
    var format: GLenum {
        precondition(_isY)
        return GLenum(GL_BGRA)
    }
}
