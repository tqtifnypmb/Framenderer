//
//  TextureOutputFrameBuffer.swift
//  SwiftyImage
//
//  Created by tqtifnypmb on 17/01/2017.
//  Copyright © 2017 tqitfnypmb. All rights reserved.
//

import Foundation
import GLKit
import OpenGLES.ES3.gl
import OpenGLES.ES3.glext

fileprivate func isSupportFastTexture() -> Bool {
    return TARGET_OS_IOS != 0 ? true : false
}

class TextureOutputFrameBuffer: OutputFrameBuffer {
    
    // fast texture
    private var _renderTarget: CVPixelBuffer!
    
    private var _texture: GLuint = 0
    private let _textureWidth: GLsizei
    private let _textureHeight: GLsizei
    private var _bitmapInfo: CGBitmapInfo!
    
    private var _frameBuffer: GLuint = 0
    
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
            configureTexture()
        } else {
            glGenTextures(1, &_texture)
            configureTexture()
        }
    }
    
    private func configureTexture() {
        glBindTexture(GLenum(GL_TEXTURE_2D), _texture)
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MAG_FILTER), GL_LINEAR)
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MIN_FILTER), GL_LINEAR)
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_S), GL_CLAMP_TO_EDGE)
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_T), GL_CLAMP_TO_EDGE)
        glBindTexture(GLenum(GL_TEXTURE_2D), 0)
    }
    
    deinit {
        if _texture != 0 {
            if !isSupportFastTexture() {        // We're not supposed to delete shared texture
                glDeleteTextures(1, &_texture)
            }
            
            _texture = 0
        }
        
        if _frameBuffer != 0 {
            glDeleteFramebuffers(1, &_frameBuffer)
            _frameBuffer = 0
        }
    }
    
    func useAsOutput() throws {
        precondition(_frameBuffer == 0)
        precondition(_texture != 0)
        
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
        try validate()
    }
    
    private func validate() throws {
        let status = glCheckFramebufferStatus(GLenum(GL_FRAMEBUFFER))
        if status != GLenum(GL_FRAMEBUFFER_COMPLETE) {
            throw GLError.invalidFramebuffer(status: status)
        }
    }
    
    func convertToImage() -> CGImage? {
        glFlush()
        
        if isSupportFastTexture() {
            let width = CVPixelBufferGetBytesPerRow(_renderTarget) / 4
            let size = width * (Int)(_textureHeight) * 4
            
            if CVPixelBufferLockBaseAddress(_renderTarget, .readOnly) != kCVReturnSuccess {
                fatalError()
            }
            
            let pixelDataPtr = CVPixelBufferGetBaseAddress(_renderTarget)!
            
            let imageDataProvider = CGDataProvider(dataInfo: nil, data: pixelDataPtr, size: size, releaseData: {_ in})!
            let cgImage = CGImage(width: Int(_textureWidth), height: Int(_textureHeight), bitsPerComponent: 8, bitsPerPixel: 32, bytesPerRow: CVPixelBufferGetBytesPerRow(_renderTarget), space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: _bitmapInfo, provider: imageDataProvider, decode: nil, shouldInterpolate: false, intent: CGColorRenderingIntent.defaultIntent)
            
            CVPixelBufferUnlockBaseAddress(_renderTarget, .readOnly)
            
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
    
    func convertToInput(bitmapInfo: CGBitmapInfo) -> InputFrameBuffer {
        glFlush()
        
        glBindTexture(GLenum(GL_TEXTURE_2D), 0)
        
        let input = TextureInputFrameBuffer(texture: _texture, width: _textureWidth, height: _textureHeight, bitmapInfo: _bitmapInfo)
        input.originalOutputFrameBuffer = self
        
        if _frameBuffer != 0 {
            glDeleteFramebuffers(1, &_frameBuffer)
            _frameBuffer = 0
        }
        return input
    }
}
