//
//  TaggedGradientFilter.swift
//  Framenderer
//
//  Created by tqtifnypmb on 28/03/2017.
//  Copyright © 2017 tqtifnypmb. All rights reserved.
//

import Foundation

fileprivate let scharr_x: [GLfloat] = [-3, 0, 3,
                                       -10, 0, 10,
                                       -3, 0, 3]

fileprivate let scharr_y: [GLfloat] = [-3, -10, -3,
                                       0, 0, 0,
                                       3, 10, 3]

/*
 * This filter do two things:
 *      1. calculate intensity gradient as same as what sobel filter do
 *      2. premultipied color with alpha channel which is then used to store gradient direction
 */
class TaggedGradientFilter: BaseFilter {
    override init() {}
    
    override public var name: String {
        return "TaggedGradientFilter"
    }
    
    override func setUniformAttributs(context ctx: Context) {
        super.setUniformAttributs(context: ctx)
        
        let texelWidth = 1 / GLfloat(ctx.inputWidth)
        let texelHeight = 1 / GLfloat(ctx.inputHeight)
        _program.setUniform(name: kXOffset, value: texelWidth)
        _program.setUniform(name: kYOffset, value: texelHeight)
        
        _program.setUniform(name: "xKernel", mat3x3: scharr_x)
        _program.setUniform(name: "yKernel", mat3x3: scharr_y)

    }
    
    override func buildProgram() throws {
        _program = try Program.create(fragmentSourcePath: "TaggedGradientFragmentShader")
    }
}
