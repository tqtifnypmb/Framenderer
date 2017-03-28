//
//  NonMaxSuppressFilter.swift
//  Framenderer
//
//  Created by tqtifnypmb on 28/03/2017.
//  Copyright © 2017 tqtifnypmb. All rights reserved.
//

import Foundation

class NonMaxSuppressFilter: BaseFilter {
    
    private let _lower: Float
    private let _upper: Float
    init(lower: Float, upper: Float) {
        _upper = upper
        _lower = lower
    }
    
    override var name: String {
        return "NonMaxSuppressFilter"
    }
    
    override func setUniformAttributs(context ctx: Context) {
        super.setUniformAttributs(context: ctx)
        
        let texelWidth = 1 / GLfloat(ctx.inputWidth)
        let texelHeight = 1 / GLfloat(ctx.inputHeight)
        _program.setUniform(name: kXOffset, value: texelWidth)
        _program.setUniform(name: kYOffset, value: texelHeight)
        
        _program.setUniform(name: "lower", value: _lower)
        _program.setUniform(name: "upper", value: _upper)
    }
    
    override func buildProgram() throws {
        _program = try Program.create(fragmentSourcePath: "NonMaxSuppressFragmentShader")
    }
}
