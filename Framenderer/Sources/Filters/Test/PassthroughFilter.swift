//
//  PassthroughFilter.swift
//  Framenderer
//
//  Created by tqtifnypmb on 22/02/2017.
//  Copyright © 2017 tqtifnypmb. All rights reserved.
//

import Foundation
import CoreGraphics
import OpenGLES.ES3.gl
import OpenGLES.ES3.glext

public class PassthroughFilter: BaseFilter {
    
    override public init() {}
    
    override func buildProgram() throws {
        _program = try Program.create(fragmentSourcePath: "PassthroughFragmentShader")
    }
    
    override public var name: String {
        return "PassthroughFilter"
    }
}
