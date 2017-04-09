//
//  FeiChenFilter.swift
//  Framenderer
//
//  Created by tqtifnypmb on 09/04/2017.
//  Copyright © 2017 tqtifnypmb. All rights reserved.
//

import Foundation

public class FeiChenFilter: BaseFilter {
    override public init() {}
    
    override public var name: String {
        return "FeiChenFilter"
    }
    
    override func buildProgram() throws {
        _program = try Program.create(fragmentSourcePath: "3x3ConvolutionFragmentShader")
    }
    
    override func setUniformAttributs(context ctx: Context) {
        super.setUniformAttributs(context: ctx)
        
        let texelWidth = 1 / GLfloat(ctx.inputWidth)
        let texelHeight = 1 / GLfloat(ctx.inputHeight)
        _program.setUniform(name: kXOffset, value: texelWidth)
        _program.setUniform(name: kYOffset, value: texelHeight)
        
        let tmp = sqrtf(2.0)
        let xKernel: [Float] = [1.0, tmp, 1.0,
                                0.0, 0.0, 0.0,
                                -1.0, -tmp, -1.0]
        
        let yKernel: [Float] = [1.0, 0.0, -1.0,
                                tmp, 0.0, -tmp,
                                1.0, 0.0, -1.0]
        
        _program.setUniform(name: "xKernel", mat3x3: xKernel)
        _program.setUniform(name: "yKernel", mat3x3: yKernel)
        _program.setUniform(name: "scale", value: 2.0 / (2.0 + tmp))
    }
}
