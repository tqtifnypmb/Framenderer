//
//  MedianFilter.swift
//  Framenderer
//
//  Created by tqtifnypmb on 11/12/2016.
//  Copyright © 2016 tqitfnypmb. All rights reserved.
//

import Foundation
import OpenGLES.ES3.gl
import OpenGLES.ES3.glext

public class MedianBlurFilter: BaseFilter {
    
    override public var name: String {
        return "MedianBlurFilter"
    }
    
    override func setUniformAttributs(context ctx: Context) {
        super.setUniformAttributs(context: ctx)
        
        let texelWidth = 1 / GLfloat(ctx.inputWidth)
        let texelHeight = 1 / GLfloat(ctx.inputHeight)
        _program.setUniform(name: kTexelWidth, value: texelWidth)
        _program.setUniform(name: kTexelHeight, value: texelHeight)
    }
    
    override func buildProgram() throws {
        _program = try Program.create(vertexSourcePath: "MedianBlurVertexShader", fragmentSourcePath: "MedianBlurFragmentShader")
    }
}
