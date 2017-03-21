//
//  ExplosureAdjustFilter.swift
//  Framenderer
//
//  Created by tqtifnypmb on 15/12/2016.
//  Copyright © 2016 tqitfnypmb. All rights reserved.
//

import Foundation
import OpenGLES.ES3.gl
import OpenGLES.ES3.glext

public class ExplosureAdjustFilter: BaseFilter {
    
    public init(value: Float = 0.25) {
        _ev = GLfloat(value)
    }
    private let _ev: GLfloat
    
    override func buildProgram() throws {
        _program = try Program.create(fragmentSourcePath: "ExplosureAdjustFragmentShader")
    }
    
    override func setUniformAttributs(context: Context) {
        super.setUniformAttributs(context: context)
        
        _program.setUniform(name: "ev", value: pow(2.0, _ev))
    }
    
    override public var name: String {
        return "ExplosureAdjustFilter"
    }
}
