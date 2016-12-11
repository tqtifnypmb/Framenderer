//
//  BoxBlurFilter.swift
//  SwiftyImage
//
//  Created by tqtifnypmb on 11/12/2016.
//  Copyright © 2016 tqitfnypmb. All rights reserved.
//

import Foundation
import OpenGLES.ES3.gl
import OpenGLES.ES3.glext

class BoxBlurFilter: TwoPassFilter {
    
    private let _kernelSize: GLfloat
    private let _vertexShaderSrc: String
    private let _fragmentShaderSrc: String
    
    init(radius: Int) {
        _kernelSize = GLfloat(radius * 2) + 1
        _vertexShaderSrc = ""
        _fragmentShaderSrc = ""
    }
    
    override func setUniformAttributs(context ctx: Context) {
        super.setUniformAttributs(context: ctx)
        
        let texelWidth = 1 / GLfloat(ctx.inputWidth)
        let texelHeight = 1 / GLfloat(ctx.inputHeight)
        _program.setUniform(name: "texelWidth", value: texelWidth)
        _program.setUniform(name: "texelHeight", value: texelHeight)
    }
    
    override func buildProgram() throws {
        _program = try Program.create(vertexSourcePath: "3x3KernelVertexShader", fragmentSourcePath: "BoxBlurFragmentShader")
        //_program2 = try Program.create(vertexSourcePath: "3x3KernelVertexShader", fragmentSourcePath: "BoxBlurFragmentShader")
    }
}
