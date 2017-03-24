//
//  ErosionFilter.swift
//  Framenderer
//
//  Created by tqtifnypmb on 23/03/2017.
//  Copyright © 2017 tqtifnypmb. All rights reserved.
//

import Foundation

public class ErosionFilter: BaseFilter {
    
    override public var name: String {
        return "ErosionFilter"
    }
    
    private let _radius: Int
    public init(radius: Int = 1) {
        _radius = radius
    }
    
    override func setUniformAttributs(context ctx: Context) {
        super.setUniformAttributs(context: ctx)
        
        let texelWidth = 1 / GLfloat(ctx.inputWidth)
        let texelHeight = 1 / GLfloat(ctx.inputHeight)
        _program.setUniform(name: kXOffset, value: texelWidth)
        _program.setUniform(name: kYOffset, value: texelHeight)
        _program.setUniform(name: "radius", value: _radius)
    }
    
    override func buildProgram() throws {
        _program = try Program.create(fragmentSourcePath: "ErosionFragmentShader")
    }
}
