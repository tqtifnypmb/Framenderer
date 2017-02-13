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

protocol InputFrameBuffer {
    func useAsInput()
    
    var bitmapInfo: CGBitmapInfo {get}
    var width: GLsizei {get}
    var height: GLsizei {get}
    var textCoor: [GLfloat] {get}
}
