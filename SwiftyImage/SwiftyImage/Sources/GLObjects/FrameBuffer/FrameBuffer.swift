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

fileprivate func isSupportFastTexture() -> Bool {
    if TARGET_IPHONE_SIMULATOR != 0 {
        return false
    } else if TARGET_OS_IPHONE != 0 {
        return true
    } else {
        return false
    }
}

class FrameBuffer: InputFrameBuffer, OutputFrameBuffer {
    
    // fast texture 
    
    private var _renderTarget: CVPixelBuffer!
    
    // input/output buffer properties
    
    private var _texture: GLuint = 0
    private var _textureWidth: GLsizei = 0
    private var _textureHeight: GLsizei = 0
    
    private var _isInputFrameBuffer = false
    
    // input buffer properties
    
    private var _rotation: Rotation = .none
    
    // output buffer properties
    
    private var _frameBuffer: GLuint = 0
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
        
        _textureWidth = GLsizei(textureInfo.width)
        _textureHeight = GLsizei(textureInfo.height)
        _rotation = rotation
        _texture = textureInfo.name
        _isInputFrameBuffer = true
    }
    
    /// Create a output framebuffer object
    init(width: GLsizei, height: GLsizei, bitmapInfo: CGBitmapInfo) throws {
        let maxTextureSize = GLsizei(Limits.max_texture_size)
        if width < maxTextureSize && height < maxTextureSize {
            _textureWidth = width
            _textureHeight = height
        } else {
            if width < height {
                _textureHeight = maxTextureSize
                _textureWidth = GLsizei(Double(maxTextureSize) * (Double(width) / Double(height)))
            } else {
                _textureWidth = maxTextureSize
                _textureHeight = GLsizei(Double(maxTextureSize) * (Double(height) / Double(width)))
            }
        }
        _bitmapInfo = bitmapInfo
        _isInputFrameBuffer = false
        
        if isSupportFastTexture() {
            // Code originally sourced from http://allmybrain.com/2011/12/08/rendering-to-a-texture-with-ios-5-texture-cache-api/
            
            let attrs: [String: [Int: Int]] = [kCVPixelBufferIOSurfacePropertiesKey as String: [:]]
            
            var pixelBuffer: CVPixelBuffer?
            if CVPixelBufferCreate(CFAllocatorGetDefault()!.takeRetainedValue(),
                                Int(_textureWidth),
                                Int(_textureHeight),
                                kCVPixelFormatType_32BGRA,
                                attrs as CFDictionary,
                                &pixelBuffer) != kCVReturnSuccess {
                throw DataError.pixelBuffer(errorDesc: "Can't create a pixel buffer")
            }
            _renderTarget = pixelBuffer
            
            TextureCacher.shared.setup(context: EAGLContext.current())
            
            let cvTexture = try TextureCacher.shared.createTexture(fromPixelBufer: _renderTarget, target: GLenum(GL_TEXTURE_2D), format: GLenum(GL_BGRA))
            assert(CVOpenGLESTextureGetTarget(cvTexture) == GLenum(GL_TEXTURE_2D))
            
            _texture = CVOpenGLESTextureGetName(cvTexture)
            glBindTexture(GLenum(GL_TEXTURE_2D), _texture)
            configureTexture()
        } else {
            glGenTextures(1, &_texture)
            glBindTexture(GLenum(GL_TEXTURE_2D), _texture)
            configureTexture()
        }
    }
    
    /// Create a input framebuffer object using samplebuffer as content
    init(sampleBuffer: CMSampleBuffer) throws {
        if let cv = CMSampleBufferGetImageBuffer(sampleBuffer) {
            CVPixelBufferLockBaseAddress(cv, .readOnly)
            
            let width = CVPixelBufferGetWidth(cv)
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
            configureTexture()
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
        if _texture != 0 {
            glDeleteTextures(1, &_texture)
            _texture = 0
        }
        
        if _frameBuffer != 0 {
            glDeleteFramebuffers(1, &_frameBuffer)
            _frameBuffer = 0
        }
    }
    
    func useAsInput() {
        precondition(isInput)
        
        glBindTexture(GLenum(GL_TEXTURE_2D), _texture)
    }
    
    func useAsOutput() {
        precondition(!isInput)
        
        if _frameBuffer != 0 {
            fatalError()
        }
        
        glGenFramebuffers(1, &_frameBuffer)
        glBindFramebuffer(GLenum(GL_FRAMEBUFFER), _frameBuffer)
        glViewport(0, 0, _textureWidth, _textureHeight)
        
        glBindTexture(GLenum(GL_TEXTURE_2D), _texture)
        
        if !isSupportFastTexture() {
            glTexImage2D(GLenum(GL_TEXTURE_2D),
                         0,
                         GL_RGBA,
                         _textureWidth,
                         _textureHeight,
                         0,
                         GLenum(GL_RGBA),
                         GLenum(GL_UNSIGNED_BYTE),
                         nil)
        }
        
        glFramebufferTexture2D(GLenum(GL_FRAMEBUFFER),
                               GLenum(GL_COLOR_ATTACHMENT0),
                               GLenum(GL_TEXTURE_2D),
                               _texture,
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
    
    func convertToInput(bitmapInfo: CGBitmapInfo) -> InputFrameBuffer {
        precondition(!isInput)
        _isInputFrameBuffer = true
        
        if _frameBuffer != 0 {
            glDeleteFramebuffers(1, &_frameBuffer)
            _frameBuffer = 0
        }
        
        _bitmapInfo = bitmapInfo
        
        return self
    }
    
    func convertToImage() -> CGImage? {
        precondition(!isInput)
        
        glFlush()
        
        if isSupportFastTexture() {
            let width = CVPixelBufferGetBytesPerRow(_renderTarget) / 4
            let size = width * (Int)(_textureHeight) * 4
            
            if CVPixelBufferLockBaseAddress(_renderTarget,
                                            .readOnly) != kCVReturnSuccess {
                fatalError()
            }
            
            let pixelDataPtr = CVPixelBufferGetBaseAddress(_renderTarget)!
            let imageDataProvider = CGDataProvider(dataInfo: &_renderTarget, data: pixelDataPtr, size: size, releaseData: { (info, _, _) in
                let renderTarget = info!.assumingMemoryBound(to: CVPixelBuffer.self)
                CVPixelBufferUnlockBaseAddress(renderTarget.pointee, .readOnly)
            })!
         
            let cgImage = CGImage(width: Int(_textureWidth), height: Int(_textureHeight), bitsPerComponent: 8, bitsPerPixel: 32, bytesPerRow: CVPixelBufferGetBytesPerRow(_renderTarget), space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: _bitmapInfo, provider: imageDataProvider, decode: nil, shouldInterpolate: false, intent: CGColorRenderingIntent.defaultIntent)
            
            return cgImage
        } else {
            var rawImageData = [GLubyte](repeating: 0, count: Int(_textureWidth * _textureHeight * 4))
            rawImageData.withUnsafeMutableBytes { ptr in
                glReadPixels(0,
                             0,
                             _textureWidth,
                             _textureHeight,
                             GLenum(GL_RGBA),
                             GLenum(GL_UNSIGNED_BYTE),
                             ptr.baseAddress)
            }
            
            var imageDataProvider: CGDataProvider!
            rawImageData.withUnsafeBytes { bytes in
                imageDataProvider = CGDataProvider(dataInfo: nil, data: bytes.baseAddress!, size: bytes.count, releaseData: { (_, _, _) in
                })
            }
            
            let cgImage = CGImage(width: Int(_textureWidth), height: Int(_textureHeight), bitsPerComponent: 8, bitsPerPixel: 32, bytesPerRow: Int(_textureWidth) * 4, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: _bitmapInfo, provider: imageDataProvider, decode: nil, shouldInterpolate: false, intent: CGColorRenderingIntent.defaultIntent)
            
            return cgImage
        }
    }
    
    private var isInput: Bool {
        return _isInputFrameBuffer
    }
    
    var width: GLsizei {
        return _textureWidth
    }
    
    var height: GLsizei {
        return _textureHeight
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
    
    var bitmapInfo: CGBitmapInfo {
        precondition(isInput)
        
        if _bitmapInfo != nil {
            return _bitmapInfo
        }
        
        if isSupportFastTexture() {
            return [CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue), .byteOrder32Little]
        } else {
            return CGBitmapInfo(rawValue: CGImageAlphaInfo.none.rawValue)
        }
        
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
