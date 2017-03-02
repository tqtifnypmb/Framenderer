//
//  ColorClampFilter.swift
//  Framenderer
//
//  Created by tqtifnypmb on 15/12/2016.
//  Copyright © 2016 tqitfnypmb. All rights reserved.
//

import Foundation
import CoreGraphics
import OpenGLES.ES3.gl
import OpenGLES.ES3.glext

public class ColorClampFilter: BaseFilter {
    
    public init(minColor: CGColor, maxColor: CGColor) {
        _max = maxColor
        _min = minColor
    }
    private let _min: CGColor
    private let _max: CGColor
    
    override func buildProgram() throws {
        _program = try Program.create(fragmentSourcePath: "ColorClampFragmentShader")
    }
    
    override func setUniformAttributs(context: Context) {
        super.setUniformAttributs(context: context)
        _program.setUniform(name: "minColor", value: _min.components!.map{ return GLfloat($0) })
        _program.setUniform(name: "maxColor", value: _max.components!.map{ return GLfloat($0) })
    }
    
    override public var name: String {
        return "ColorClampFilter"
    }
}
