//
//  InputFrameBuffer.swift
//  SwiftyImage
//
//  Created by tqtifnypmb on 04/01/2017.
//  Copyright © 2017 tqitfnypmb. All rights reserved.
//

import OpenGLES.ES3.gl
import OpenGLES.ES3.glext
import CoreGraphics
import CoreVideo

public protocol InputFrameBuffer {
    func useAsInput()
    func writeTo(pixelBuffer: CVPixelBuffer)
    
    var bitmapInfo: CGBitmapInfo {get}
    var width: GLsizei {get}
    var height: GLsizei {get}
    var textCoor: [GLfloat] {get}
}

func write(texture: GLuint, toPixelBuffer pb: CVPixelBuffer) throws {
    if kCVReturnSuccess != CVPixelBufferLockBaseAddress(pb, .init(rawValue: 0)) {
        throw DataError.pixelBuffer(errorDesc: "Can't lock CVPixelBuffer")
    }
    
    // TODO
    
    if kCVReturnSuccess != CVPixelBufferUnlockBaseAddress(pb, .init(rawValue: 0)) {
        throw DataError.pixelBuffer(errorDesc: "Can't unlock CVPixelBuffer")
    }
}
