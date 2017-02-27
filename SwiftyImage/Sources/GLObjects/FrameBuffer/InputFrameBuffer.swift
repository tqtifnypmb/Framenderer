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
    
    var bitmapInfo: CGBitmapInfo {get}
    var width: GLsizei {get}
    var height: GLsizei {get}
    var textCoor: [GLfloat] {get}
}

enum Rotation {
    case none
    case ccw90
    case ccw180
    case ccw270
}

func textCoordinate(forRotation rotation: Rotation, flipHorizontally: Bool, flipVertically: Bool) -> [GLfloat] {
    switch rotation {
    case .none:
        if flipHorizontally {
            return [
                1.0, 0.0,
                1.0, 1.0,
                0.0, 0.0,
                0.0, 1.0
            ]
        } else {
            return [
                0.0, 0.0,
                0.0, 1.0,
                1.0, 0.0,
                1.0, 1.0
            ]
        }
        
    case .ccw90:
        if flipHorizontally {
            return [
                0.0, 0.0,
                1.0, 0.0,
                0.0, 1.0,
                1.0, 1.0
            ]
        } else {
            return [
                0.0, 1.0,
                1.0, 1.0,
                0.0, 0.0,
                1.0, 0.0
            ]
        }
        
    case .ccw180:
        if flipHorizontally {
            return [
                0.0, 1.0,
                0.0, 0.0,
                1.0, 1.0,
                1.0, 0.0
            ]
        } else {
            return [
                1.0, 1.0,
                1.0, 0.0,
                0.0, 1.0,
                0.0, 0.0
            ]
        }
        
    case .ccw270:
        if flipHorizontally {
            return [
                1.0, 1.0,
                0.0, 1.0,
                1.0, 0.0,
                0.0, 0.0
            ]
        } else {
            return [
                1.0, 0.0,
                0.0, 0.0,
                1.0, 1.0,
                0.0, 1.0
            ]
        }
    }
}
