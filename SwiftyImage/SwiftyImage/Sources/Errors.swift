//
//  Errors.swift
//  SwiftyImage
//
//  Created by tqtifnypmb on 08/12/2016.
//  Copyright © 2016 tqitfnypmb. All rights reserved.
//

import Foundation

public enum GLError: Error {
    case compile(type: String, infoLog: String)
    case link(infoLog: String)
}

extension GLError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case let .compile(type, infoLog):
            return "[Compile Error] in: \(type) shader \n infoLog: \(infoLog)"
            
        case let .link(infoLog):
            return "[Link Error] infoLog: \(infoLog)"
        }
    }
}
