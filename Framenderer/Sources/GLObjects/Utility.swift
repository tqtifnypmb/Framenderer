//
//  Utility.swift
//  Framenderer
//
//  Created by tqtifnypmb on 28/02/2017.
//  Copyright © 2017 tqtifnypmb. All rights reserved.
//

import Foundation

// MARK: - Text coordinate

func flipTextCoorVertically(textCoor: [GLfloat]) -> [GLfloat] {
    return [
        textCoor[2], textCoor[3],
        textCoor[0], textCoor[1],
        textCoor[6], textCoor[7],
        textCoor[4], textCoor[5]
    ]
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

// MARK: - Texture size calculation

func scaledTextureSize(width: GLsizei, height: GLsizei, originalWidth ow: GLsizei, originalHeight oh: GLsizei, scaleMode: ContentScaleMode) -> (GLsizei, GLsizei) {
    switch scaleMode {
    case .scaleToFill:
        return (width, height)
        
    case .aspectFill:
        let w2h = Double(ow) / Double(oh)
        if width > height {
            let w = Double(height) * w2h
            let rw = GLsizei(w) > width ? width : GLsizei(w)
            return (rw, height)
        } else {
            let h = Double(width) / w2h
            let rh = GLsizei(h) > height ? height : GLsizei(h)
            return (width, rh)
        }
        
    case .aspectFit:
        let w2h = Double(width) / Double(height)
        let ow2oh = Double(ow) / Double(oh)
        if w2h > ow2oh {
            return (GLsizei(Double(ow) * Double(height) / Double(oh)), height)
        } else {
            return (width, GLsizei(Double(oh) * Double(width) / Double(ow)))
        }
    }
}
