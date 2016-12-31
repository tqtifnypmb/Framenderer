//
//  TextureCacher.swift
//  SwiftyImage
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
        var cacher: CVOpenGLESTextureCache?
        assert(CVOpenGLESTextureCacheCreate(CFAllocatorGetDefault()!.takeRetainedValue(), nil, context, nil, &cacher) == kCVReturnSuccess)
        
        _cacher = cacher
    }
    
    func createTexture(fromSampleBuffer smb: CMSampleBuffer, target: GLenum, format: GLenum) throws -> CVOpenGLESTexture {
        if let cv = CMSampleBufferGetImageBuffer(smb) {
            var texture: CVOpenGLESTexture?
            
            let width = CVPixelBufferGetWidth(cv)
            let height = CVPixelBufferGetHeight(cv)
            assert(CVOpenGLESTextureCacheCreateTextureFromImage(CFAllocatorGetDefault()!.takeRetainedValue(), _cacher, cv, nil, target, GL_RGBA, GLsizei(width), GLsizei(height), format, GLenum(GL_UNSIGNED_BYTE), 0, &texture) == kCVReturnSuccess)
            return texture!
        } else {
            throw DataError.sample(errorDesc: "CMSampleBuffer doesn't contain image data")
        }
    }
}
