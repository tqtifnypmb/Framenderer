//
//  GammaAdjustFilter.swift
//  SwiftyImage
//
//  Created by tqtifnypmb on 15/12/2016.
//  Copyright © 2016 tqitfnypmb. All rights reserved.
//

import Foundation
import OpenGLES.ES3.gl
import OpenGLES.ES3.glext

public class GammaAdjustFilter: BaseFilter {
    public init(value: Float = 0.75) {
        _value = value
    }
    private let _value: GLfloat
    
    override func buildProgram() throws {
        _program = try Program.create(fragmentSourcePath: "GammaAdjustFragmentShader")
    }
    
    override func setUniformAttributs(context: Context) {
        super.setUniformAttributs(context: context)
        
        _program.setUniform(name: "adjust", value: _value)
    }
    
    override public var name: String {
        return "GammaAdjustFilter"
    }
}
