//
//  SobelFilter.swift
//  Framenderer
//
//  Created by tqtifnypmb on 22/03/2017.
//  Copyright © 2017 tqtifnypmb. All rights reserved.
//

import Foundation

fileprivate let scharr_x: [GLfloat] = [-3, 0, 3,
                                       -10, 0, 10,
                                       -3, 0, 3]

fileprivate let scharr_y: [GLfloat] = [-3, -10, -3,
                                       0, 0, 0,
                                       3, 10, 3]

// ref: http://hlevkin.com/articles/SobelScharrGradients5x5.pdf

fileprivate let sobel_5x5_x: [GLfloat] = [-5, -8, -10, -8, -5,
                                          -4, -10, -20, -10, -4,
                                          0, 0, 0, 0, 0,
                                          4, 10, 20, 10, 4,
                                          5, 8, 10, 8, 5]

fileprivate let sobel_5x5_y: [GLfloat] = [-5, -4, 0, 4, 5,
                                          -8, -10, 0, 10, 10,
                                          -10, -20, 0, 20, 10,
                                          -8, -10, 0, 10, 8,
                                          -5, -4, 0, 4, 5]

public class SobelFilter: BaseFilter {
    private let _radius: Int
    public init(radius: Int = 1) {
        precondition(radius == 1 || radius == 2)
        
        _radius = max(1, radius)
    }
    
    override public var name: String {
        return "SobelFilter"
    }
    
    override func setUniformAttributs(context ctx: Context) {
        super.setUniformAttributs(context: ctx)

        let texelWidth = 1 / GLfloat(ctx.inputWidth)
        let texelHeight = 1 / GLfloat(ctx.inputHeight)
        _program.setUniform(name: kXOffset, value: texelWidth)
        _program.setUniform(name: kYOffset, value: texelHeight)
        _program.setUniform(name: "radius", value: Float(_radius))
        
        if _radius == 1 {
            _program.setUniform(name: "xKernel", mat3x3: scharr_x)
            _program.setUniform(name: "yKernel", mat3x3: scharr_y)
        } else {
            _program.setUniform(name: "xKernel", kernel: sobel_5x5_x)
            _program.setUniform(name: "yKernel", kernel: sobel_5x5_y)
        }
    }
    
    override func buildProgram() throws {
        if _radius == 1 {
            _program = try Program.create(fragmentSourcePath: "SobelFragmentShader")
        } else {
            _program = try Program.create(fragmentSourcePath: "SobelFragmentShader5x5")
        }
    }
}
