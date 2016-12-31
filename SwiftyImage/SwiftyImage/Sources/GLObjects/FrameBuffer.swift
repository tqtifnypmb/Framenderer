//
//  FrameBuffer.swift
//  SwiftyImage
//
//  Created by tqtifnypmb on 09/12/2016.
//  Copyright © 2016 tqitfnypmb. All rights reserved.
//

import Foundation
import CoreGraphics
import AVFoundation
import GLKit
import OpenGLES.ES3.gl
import OpenGLES.ES3.glext

class FrameBuffer {
    
    // input buffer properties
    
    private var _inputTexture: GLKTextureInfo!
    private var _rotation: Rotation = .none
    private var _convertedFromOutput: Bool = false
    private var _inputCVTexture: CVOpenGLESTexture!
    
    // output buffer properties
    
    private var _frameBuffer: GLuint = 0
    private var _outputTexture: GLuint = 0
    private var _outputWidth: GLsizei = 0
    private var _outputHeight: GLsizei = 0
    private var _bitmapInfo: CGBitmapInfo!
    
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
    
    init(width: GLsizei, height: GLsizei, bitmapInfo: CGBitmapInfo) {
        let maxTextureSize = GLsizei(Limits.max_texture_size)
        if width < maxTextureSize && height < maxTextureSize {
            _outputWidth = width
            _outputHeight = height
        } else {
            if width < height {
                _outputHeight = maxTextureSize
                _outputWidth = GLsizei(Double(maxTextureSize) * (Double(width) / Double(height)))
            } else {
                _outputWidth = maxTextureSize
                _outputHeight = GLsizei(Double(maxTextureSize) * (Double(height) / Double(width)))
            }
        }
        _bitmapInfo = bitmapInfo
        
        glGenTextures(1, &_outputTexture)
        glBindTexture(GLenum(GL_TEXTURE_2D), _outputTexture)
        configureTexture()
    }
    
    init(sampleBuffer: CMSampleBuffer) throws {
        _inputCVTexture = try TextureCacher.shared.createTexture(fromSampleBuffer: sampleBuffer, target: GLenum(GL_TEXTURE_2D), format: GLenum(GL_RGBA))
        configureTexture()
    }
    
    private func configureTexture() {
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MAG_FILTER), GL_LINEAR)
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MIN_FILTER), GL_LINEAR)
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_S), GL_CLAMP_TO_EDGE)
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_T), GL_CLAMP_TO_EDGE)
    }
    
    deinit {
        if isInput {
            var toDelete = _convertedFromOutput ? _outputTexture : _inputTexture.name
            glDeleteTextures(1, &toDelete)
        } else if _frameBuffer != 0 {
            glDeleteFramebuffers(1, &_frameBuffer)
            _frameBuffer = 0
        }
    }
    
    func useAsInput() {
        precondition(isInput)
        
        if _convertedFromOutput {
            glBindTexture(GLenum(GL_TEXTURE_2D), _outputTexture)
        } else {
            glBindTexture(_inputTexture.target, _inputTexture.name)
        }
    }
    
    func useAsOutput() {
        precondition(!isInput)
        
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
    
    func convertToInput(bitmapInfo: CGBitmapInfo) {
        precondition(!isInput)
        precondition(!_convertedFromOutput)
        
        if _frameBuffer != 0 {
            glDeleteFramebuffers(1, &_frameBuffer)
            _frameBuffer = 0
        }
        
        _bitmapInfo = bitmapInfo
        _convertedFromOutput = true
    }
    
    func convertToImage() -> CGImage? {
        precondition(!isInput)
        
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
        
        let cgImage = CGImage(width: Int(_outputWidth), height: Int(_outputHeight), bitsPerComponent: 8, bitsPerPixel: 32, bytesPerRow: Int(_outputWidth) * 4, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: _bitmapInfo, provider: imageDataProvider, decode: nil, shouldInterpolate: false, intent: CGColorRenderingIntent.defaultIntent)
        return cgImage
    }
    
    private var isInput: Bool {
        return _inputTexture != nil || _convertedFromOutput
    }
    
    var width: GLsizei {
        return isInput ? _convertedFromOutput ? _outputWidth : GLsizei(_inputTexture.width) : _outputWidth
    }
    
    var height: GLsizei {
        return isInput ? _convertedFromOutput ? _outputHeight : GLsizei(_inputTexture.height) : _outputHeight
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
        precondition(isInput)
        
        if _convertedFromOutput {
            return _bitmapInfo
        }
        
        switch _inputTexture.alphaState {
        case .none:
            return CGBitmapInfo(rawValue: CGImageAlphaInfo.none.rawValue)
            
        case .premultiplied:
            return CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
            
        case .nonPremultiplied:
            return CGBitmapInfo(rawValue: CGImageAlphaInfo.none.rawValue)
        }
    }
}
