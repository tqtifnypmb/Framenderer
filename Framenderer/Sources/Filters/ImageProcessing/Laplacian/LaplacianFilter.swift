//
//  LaplacianFilter.swift
//  Framenderer
//
//  Created by tqtifnypmb on 24/03/2017.
//  Copyright © 2017 tqtifnypmb. All rights reserved.
//

import Foundation

public class LaplacianFilter: BaseFilter {
    
    override public init() {}
    
    override public var name: String {
        return "LaplacianFilter"
    }
    
    override func buildProgram() throws {
        _program = try Program.create(fragmentSourcePath: "LaplacianFragmentShader")
    }
    
    override func setUniformAttributs(context ctx: Context) {
        super.setUniformAttributs(context: ctx)
        
        let texelWidth = 1 / GLfloat(ctx.inputWidth)
        let texelHeight = 1 / GLfloat(ctx.inputHeight)
        _program.setUniform(name: kXOffset, value: texelWidth)
        _program.setUniform(name: kYOffset, value: texelHeight)
    }
}
