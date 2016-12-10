//
//  FrameBuffer.swift
//  SwiftyImage
//
//  Created by tqtifnypmb on 09/12/2016.
//  Copyright © 2016 tqitfnypmb. All rights reserved.
//

import Foundation
import CoreGraphics
import GLKit
import OpenGLES.ES3.gl
import OpenGLES.ES3.glext

class FrameBuffer {
    
    // input buffer properties
    
    private var _inputTexture: GLKTextureInfo!
    private var _rotation: Rotation = .none
    
    // output buffer properties
    
    private var _frameBuffer: GLuint = 0
    private var _outputTexture: GLuint = 0
    private var _outputWidth: GLsizei = 0
    private var _outputHeight: GLsizei = 0
    
    enum Rotation {
        case none
        case ccw90
        case ccw180
        case ccw270
    }
    
    init(texture: CGImage, rotation: Rotation = .none) throws {
        
        _rotation = rotation
        _inputTexture = try GLKTextureLoader.texture(with: texture, options: [GLKTextureLoaderOriginBottomLeft : false])
        assert(_inputTexture.target == GLenum(GL_TEXTURE_2D))
        
        switch _inputTexture.alphaState {
        case .premultiplied:
            print("Prem")
            
        case .nonPremultiplied:
            print("non Prem")
            
        default:
            print("None")
        }
        
        switch texture.alphaInfo {
        case .premultipliedLast:
            print("Prem")
            
        case .premultipliedFirst:
            print("non Prem")
            
        default:
            print("None")
        }
    }
    
    init(width: GLsizei, height: GLsizei) {
        _outputWidth = width
        _outputHeight = height
        
        glGenTextures(1, &_outputTexture)
        glBindTexture(GLenum(GL_TEXTURE_2D), _outputTexture)
        configureTexture()
    }
    
    private func configureTexture() {
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MAG_FILTER), GL_LINEAR)
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MIN_FILTER), GL_LINEAR)
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_S), GL_CLAMP_TO_EDGE)
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_T), GL_CLAMP_TO_EDGE)
    }
    
    deinit {
        if _frameBuffer != 0 {
            glDeleteFramebuffers(1, &_frameBuffer)
        }
        
        if isInput {
            var name = _inputTexture.name
            glDeleteTextures(1, &name)
        }
    }
    
    func useAsInput() {
        glBindTexture(_inputTexture.target, _inputTexture.name)
    }
    
    func useAsOutput() {
        if _frameBuffer != 0 {
            fatalError()
        }
        
        glGenFramebuffers(1, &_frameBuffer)
        glBindFramebuffer(GLenum(GL_FRAMEBUFFER), _frameBuffer)
        glViewport(0, 0, _outputWidth, _outputHeight)
        
        glBindTexture(GLenum(GL_TEXTURE_2D), _outputTexture)
        glTexImage2D(GLenum(GL_TEXTURE_2D),
                     0,
                     GL_RGBA,
                     _outputWidth,
                     _outputHeight,
                     0,
                     GLenum(GL_RGBA),
                     GLenum(GL_UNSIGNED_BYTE),
                     nil)
        glFramebufferTexture2D(GLenum(GL_FRAMEBUFFER),
                               GLenum(GL_COLOR_ATTACHMENT0),
                               GLenum(GL_TEXTURE_2D),
                               _outputTexture,
                               0)
        glBindTexture(GLenum(GL_TEXTURE_2D), 0)
        validate()
    }
    
    private func validate() {
        let status = glCheckFramebufferStatus(GLenum(GL_FRAMEBUFFER))
        if status != GLenum(GL_FRAMEBUFFER_COMPLETE) {
            fatalError("\(status)")
        }
    }
    
    func outputImage(bitmapInfo: CGBitmapInfo) -> CGImage? {
        if isInput {
            fatalError()
        }
        
        //glBindFramebuffer(GLenum(GL_FRAMEBUFFER), _frameBuffer)
        //glViewport(0, 0, _outputWidth, _outputHeight)
        
        var rawImageData = [GLubyte](repeating: 0, count: Int(_outputWidth * _outputHeight * 4))
        rawImageData.withUnsafeMutableBytes { ptr in
            glReadPixels(0,
                         0,
                         _outputWidth,
                         _outputHeight,
                         GLenum(GL_RGBA),
                         GLenum(GL_UNSIGNED_BYTE),
                         ptr.baseAddress)
        }

        var imageDataProvider: CGDataProvider!
        rawImageData.withUnsafeBytes { bytes in
            imageDataProvider = CGDataProvider(dataInfo: nil, data: bytes.baseAddress!, size: bytes.count, releaseData: { (_, _, _) in
            })
        }
        
        let cgImage = CGImage(width: Int(_outputWidth), height: Int(_outputHeight), bitsPerComponent: 8, bitsPerPixel: 32, bytesPerRow: Int(_outputWidth) * 4, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: bitmapInfo, provider: imageDataProvider, decode: nil, shouldInterpolate: false, intent: CGColorRenderingIntent.defaultIntent)
        return cgImage
    }
    
    private var isInput: Bool {
        return _inputTexture != nil
    }
    
    var width: GLsizei {
        return isInput ? GLsizei(_inputTexture.width) : _outputWidth
    }
    
    var height: GLsizei {
        return isInput ? GLsizei(_inputTexture.height) : _outputHeight
    }
    
    /// Why ??
    var textCoor: [GLfloat] {
        switch _rotation {
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
    
    var bitmapInfoForInput: CGBitmapInfo {
        if !isInput {
            fatalError()
        }
        
        switch _inputTexture.alphaState {
        case .none:
            return CGBitmapInfo(rawValue: CGImageAlphaInfo.none.rawValue)
            
        case .premultiplied:
            return CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
            
        case .nonPremultiplied:
            return CGBitmapInfo(rawValue: CGImageAlphaInfo.last.rawValue)
        }
    }
}
