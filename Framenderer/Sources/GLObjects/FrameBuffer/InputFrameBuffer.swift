//
//  InputFrameBuffer.swift
//  Framenderer
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
    func textCoorFlipVertically(flip: Bool)
    
    var width: GLsizei { get }
    var height: GLsizei { get }
    var textCoor: [GLfloat] { get }
    var format: GLenum { get }
}

enum Rotation {
    case none
    case ccw90
    case ccw180
    case ccw270
}
