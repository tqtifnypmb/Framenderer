//
//  Errors.swift
//  SwiftyImage
//
//  Created by tqtifnypmb on 08/12/2016.
//  Copyright © 2016 tqitfnypmb. All rights reserved.
//

import Foundation
import OpenGLES.ES3.gl
import OpenGLES.ES3.glext

public enum GLError: Error {
    case compile(type: String, infoLog: String)
    case link(infoLog: String)
    case invalidFramebuffer(status: GLenum)
}

extension GLError: LocalizedError {
    public var errorDescription: String? {
        let glError = glGetError()
        switch self {
        case let .compile(type, infoLog):
            return "[Compile Error] in: \(type) shader infoLog: \(infoLog) [glError]: \(glError) \n"
            
        case let .link(infoLog):
            return "[Link Error] infoLog: \(infoLog) [glError]: \(glError) \n"
            
        case let .invalidFramebuffer(status):
            return "[Invalid Framebuffer] status: \(status) [glError]: \(glError) \n"
        }
    }
}

public enum DataError: Error {
    case sample(errorDesc: String)
    case pixelBuffer(errorDesc: String)
    case disorderFrame(errorDesc: String)
}

extension DataError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case let .sample(errorDesc):
            return "[Sample Error] description: \(errorDesc)"
        
        case let .pixelBuffer(errorDesc):
            return "[Buffer Error] description: \(errorDesc)"
        
        case let .disorderFrame(errorDesc):
            return "[Frame Input Error] description: \(errorDesc)"
        }
    }
}

public enum AVAssetSettingsError: Error {
    case assetWriter(errorDessc: String)
}

extension AVAssetSettingsError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case let .assetWriter(errorDesc):
            return "[AVAsset Settings Error] description: \(errorDesc)"
        }
    }
}

public enum FilterError: Error {
    case filterError(name: String, error: String)
}

extension FilterError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case let .filterError(name, error):
            return "[Filter]: \(name) " + error
        }
    }
}
