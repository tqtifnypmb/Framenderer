//
//  TextureCacher.swift
//  Framenderer
//
//  Created by tqtifnypmb on 31/12/2016.
//  Copyright © 2016 tqitfnypmb. All rights reserved.
//

import Foundation
import CoreMedia
import OpenGLES.ES3.gl
import OpenGLES.ES3.glext

class TextureCacher {
    
    private var _cacher: CVOpenGLESTextureCache!
    
    static var shared: TextureCacher! = {
        return TextureCacher()
    }()
    
    var cacher: CVOpenGLESTextureCache! = nil
    
    func setup(context: EAGLContext) {
        guard _cacher == nil else { return }
        
        var cacher: CVOpenGLESTextureCache?
        if CVOpenGLESTextureCacheCreate(CFAllocatorGetDefault()!.takeRetainedValue(),
                                            nil,
                                            context,
                                            nil,
                                            &cacher) != kCVReturnSuccess {
            fatalError("Can't create texture cache")
        }
        
        _cacher = cacher
    }
    
    func createTexture(fromPixelBufer pb: CVPixelBuffer, target: GLenum, format: GLenum) throws -> CVOpenGLESTexture {
        let width = CVPixelBufferGetWidth(pb)
        let height = CVPixelBufferGetHeight(pb)
        return try createTexture(fromPixelBuffer: pb, target: target, internalFormat:GL_RGBA, format: format, width: GLsizei(width), height: GLsizei(height), planarIndex: 0)
    }
    
    func createTexture(fromPixelBuffer pb: CVPixelBuffer, target: GLenum, internalFormat: GLint, format: GLenum, width: GLsizei, height: GLsizei, planarIndex: Int) throws -> CVOpenGLESTexture {
        var texture: CVOpenGLESTexture?
        
        if CVOpenGLESTextureCacheCreateTextureFromImage(CFAllocatorGetDefault()!.takeRetainedValue(),
                                                        _cacher,
                                                        pb,
                                                        nil,
                                                        target,
                                                        internalFormat,
                                                        width,
                                                        height,
                                                        format,
                                                        GLenum(GL_UNSIGNED_BYTE),
                                                        planarIndex,
                                                        &texture) == kCVReturnSuccess {
            return texture!
        } else {
            throw DataError.sample(errorDesc: "Can't create texture from CVImageBuffer")
        }
    }
}
