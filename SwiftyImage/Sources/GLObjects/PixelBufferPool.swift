//
//  PixelBufferPool.swift
//  SwiftyImage
//
//  Created by tqtifnypmb on 24/02/2017.
//  Copyright © 2017 tqtifnypmb. All rights reserved.
//

import Foundation
import CoreMedia

class PixelBufferPool {
    
    private static var _pool: CVPixelBufferPool?
    private static var _width: GLsizei = 0
    private static var _height: GLsizei = 0
    
    static func pool(width: GLsizei, height: GLsizei) throws -> CVPixelBufferPool {
        if _width == width && _height == height, let pool = _pool {
            return pool
        }
        
        let attr: [String: Any] = [kCVPixelBufferPixelFormatTypeKey as String: kCMPixelFormat_32BGRA,
                                   kCVPixelBufferWidthKey as String: Int(width),
                                   kCVPixelBufferHeightKey as String: Int(height),
                                   kCVPixelBufferOpenGLCompatibilityKey as String: true,
                                   kCVPixelBufferIOSurfacePropertiesKey as String: [:]]
        
        var pool: CVPixelBufferPool?
        
        let ret = CVPixelBufferPoolCreate(nil, nil, attr as CFDictionary, &pool)
        if kCVReturnSuccess != ret {
            switch ret {
            case kCVReturnInvalidSize:
                throw DataError.pixelBuffer(errorDesc: "Can't create CVPixelBufferPool with width:\(width), height\(height)")
                
            case kCVReturnInvalidArgument:
                throw DataError.pixelBuffer(errorDesc: "Can't create CVPixelBufferPool because of Invalid Argument")
                
            case kCVReturnInvalidPixelFormat:
                throw DataError.pixelBuffer(errorDesc: "Can't create CVPixelBufferPool because of Invalid Pixel Format")
                
            case kCVReturnInvalidPoolAttributes:
                throw DataError.pixelBuffer(errorDesc: "Can't create CVPixelBufferPool because of Invalid Pool Attributes")
                
            case kCVReturnInvalidPixelBufferAttributes:
                throw DataError.pixelBuffer(errorDesc: "Can't create CVPixelBufferPool because of Invalid Pixel Buffer Attributes")
                
            default:
                throw DataError.pixelBuffer(errorDesc: "Can't create CVPixelBufferPool")
            }
        }
        
        #if DEBUG
            if _pool != nil {
                print("[CVPixelBufferPool] Something bad happended")
            }
        #endif
        
        _width = width
        _height = height
        _pool = pool
        return _pool!
    }
}
