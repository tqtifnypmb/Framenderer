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
    
    private var _pixelBuffer: CVPixelBuffer!
    
    // input buffer properties
    
    //private var _inputTexture: GLKTextureInfo!
    private var _rotation: Rotation = .none
    private var _convertedFromOutput: Bool = false
    private var _inputTexture: GLuint = 0
    private var _inputWidth: GLsizei = 0
    private var _inputHeight: GLsizei = 0
    
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
    
    /// Create a input framebuffer object using `texture` as content
    init(texture: CGImage, rotation: Rotation = .none) throws {
        
        let textureInfo = try GLKTextureLoader.texture(with: texture, options: [GLKTextureLoaderOriginBottomLeft : false])
        assert(textureInfo.target == GLenum(GL_TEXTURE_2D))
        
        switch textureInfo.alphaState {
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
        
        _inputWidth = GLsizei(textureInfo.width)
        _inputHeight = GLsizei(textureInfo.height)
        _rotation = rotation
        _inputTexture = textureInfo.name
    }
    
    /// Create a output framebuffer object
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
    
    /// Create a input framebuffer object using samplebuffer as content
    init(sampleBuffer: CMSampleBuffer) throws {
        if let cv = CMSampleBufferGetImageBuffer(sampleBuffer) {
            let width = CVPixelBufferGetWidth(cv)
            let height = CVPixelBufferGetHeight(cv)
            
            CVPixelBufferLockBaseAddress(cv, .readOnly)
            
            glGenTextures(1, &_inputTexture)
            glBindTexture(GLenum(GL_TEXTURE_2D), _inputTexture)
            glTexImage2D(GLenum(GL_TEXTURE_2D),
                         0,
                         GL_RGBA, GLsizei(width),
                         GLsizei(height),
                         0,
                         GLenum(GL_BGRA),
                         GLenum(GL_UNSIGNED_BYTE),
                         CVPixelBufferGetBaseAddress(cv)!)
            
            CVPixelBufferUnlockBaseAddress(cv, .readOnly)
            
            _inputWidth = GLsizei(width)
            _inputHeight = GLsizei(height)
            configureTexture()
            
//            let width = CVPixelBufferGetWidth(cv)
//            let height = CVPixelBufferGetHeight(cv)
//            
//            // Code originally sourced from http://allmybrain.com/2011/12/08/rendering-to-a-texture-with-ios-5-texture-cache-api/
//            
//            var keyCallback = kCFTypeDictionaryKeyCallBacks
//            var valueCallback = kCFTypeDictionaryValueCallBacks
//            var empty = CFDictionaryCreate(CFAllocatorGetDefault()!.takeRetainedValue(),
//                                           nil,
//                                           nil,
//                                           0,
//                                           &keyCallback,
//                                           &valueCallback)
//            let attrs = CFDictionaryCreateMutable(CFAllocatorGetDefault()!.takeRetainedValue(),
//                                                  1,
//                                                  &keyCallback,
//                                                  &valueCallback)
//            
//            var pixelBuffer: CVPixelBuffer?
//            var ioSurfaceKey = kCVPixelBufferIOSurfacePropertiesKey
//            CFDictionarySetValue(attrs, &ioSurfaceKey, &empty)
//            CVPixelBufferCreate(CFAllocatorGetDefault()!.takeRetainedValue(),
//                                width,
//                                height,
//                                kCVPixelFormatType_32BGRA,
//                                attrs,
//                                &pixelBuffer)
//            _pixelBuffer = pixelBuffer
//            
//            TextureCacher.shared.setup(context: context.eaglContext)
//            
//            let cvTexture = try TextureCacher.shared.createTexture(fromPixelBufer: _pixelBuffer, target: GLenum(GL_TEXTURE_2D), format: GLenum(GL_RGBA))
//            assert(CVOpenGLESTextureGetTarget(cvTexture) == GLenum(GL_TEXTURE_2D))
//            
//            _inputWidth = GLsizei(width)
//            _inputHeight = GLsizei(height)
//            _inputTexture = CVOpenGLESTextureGetName(cvTexture)
//            glBindTexture(GLenum(GL_TEXTURE_2D), _inputTexture)
//            
//            configureTexture()
        } else {
            throw DataError.sample(errorDesc: "CMSampleBuffer doesn't contain image data")
        }
    }
    
    private func configureTexture() {
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MAG_FILTER), GL_LINEAR)
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MIN_FILTER), GL_LINEAR)
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_S), GL_CLAMP_TO_EDGE)
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_T), GL_CLAMP_TO_EDGE)
    }
    
    deinit {
        if isInput {
            var toDelete = _convertedFromOutput ? _outputTexture : _inputTexture
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
            glBindTexture(GLenum(GL_TEXTURE_2D), _inputTexture)
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
        return _inputTexture != 0 || _convertedFromOutput
    }
    
    var width: GLsizei {
        return isInput ? _convertedFromOutput ? _outputWidth : _inputWidth : _outputWidth
    }
    
    var height: GLsizei {
        return isInput ? _convertedFromOutput ? _outputHeight : _inputHeight : _outputHeight
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
        
        return CGBitmapInfo(rawValue: CGImageAlphaInfo.none.rawValue)
//        switch _inputTexture.alphaState {
//        case .none:
//            return CGBitmapInfo(rawValue: CGImageAlphaInfo.none.rawValue)
//            
//        case .premultiplied:
//            return CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
//            
//        case .nonPremultiplied:
//            return CGBitmapInfo(rawValue: CGImageAlphaInfo.none.rawValue)
//        }
    }
}
