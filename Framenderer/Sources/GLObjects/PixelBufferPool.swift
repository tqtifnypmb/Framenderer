//
//  PixelBufferPool.swift
//  Framenderer
//
//  Created by tqtifnypmb on 24/02/2017.
//  Copyright © 2017 tqtifnypmb. All rights reserved.
//

import Foundation
import CoreMedia

class PixelBufferPool {
    
    private var _pools: [String: CVPixelBufferPool] = [:]

    static var shared: PixelBufferPool! = {
        return PixelBufferPool()
    }()
    
    private func cahcedPool(width: GLsizei, height: GLsizei) -> CVPixelBufferPool? {
        let key = "\(width)_\(height)"
        return _pools[key]
    }
    
    private func createPool(width: GLsizei, height: GLsizei) throws -> CVPixelBufferPool {
        var attr: [String: Any] = [kCVPixelBufferPixelFormatTypeKey as String: kCMPixelFormat_32BGRA,
                                   kCVPixelBufferWidthKey as String: Int(width),
                                   kCVPixelBufferHeightKey as String: Int(height),
                                   kCVPixelBufferIOSurfacePropertiesKey as String: [:]]
        if #available(iOS 9, *) {
            attr[kCVPixelBufferOpenGLESTextureCacheCompatibilityKey as String] = true
        }
        
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
        
        let key = "\(width)_\(height)"
        _pools[key] = pool
        
        return pool!
    }
    
    func pool(width: GLsizei, height: GLsizei) throws -> CVPixelBufferPool {
        if let pool = cahcedPool(width: width, height: height) {
            return pool
        } else {
            return try createPool(width: width, height: height)
        }
    }
    
    func drain() {
        _pools.forEach { CVPixelBufferPoolFlush($0 as! CVPixelBufferPool, [])}
        _pools.removeAll()
    }
}
