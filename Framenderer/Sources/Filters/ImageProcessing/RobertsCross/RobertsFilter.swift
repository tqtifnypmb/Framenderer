//
//  RobertsFilter.swift
//  Framenderer
//
//  Created by tqtifnypmb on 30/03/2017.
//  Copyright © 2017 tqtifnypmb. All rights reserved.
//

import Foundation

public class RobertsFilter: BaseFilter {
    public override init() {}
    
    override public var name: String {
        return "RobertsFilter"
    }
    
    override func buildProgram() throws {
        _program = try Program.create(fragmentSourcePath: "RobersFragmentShader")
    }
    
    override func setUniformAttributs(context ctx: Context) {
        super.setUniformAttributs(context: ctx)
        
        let texelWidth = 1 / GLfloat(ctx.inputWidth)
        let texelHeight = 1 / GLfloat(ctx.inputHeight)
        _program.setUniform(name: kXOffset, value: texelWidth)
        _program.setUniform(name: kYOffset, value: texelHeight)
    }
}
