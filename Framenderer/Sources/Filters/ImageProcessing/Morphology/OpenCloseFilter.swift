//
//  OpenCloseFilter.swift
//  Framenderer
//
//  Created by tqtifnypmb on 23/03/2017.
//  Copyright © 2017 tqtifnypmb. All rights reserved.
//

import Foundation

class OpenCloseFilter: TwoPassFilter {
    
    private let _radius: Int
    private let _op: MorphologyFilter.Operation
    init(radius: Int, operation: MorphologyFilter.Operation) {
        _radius = radius
        _op = operation
    }
    
    override public var name: String {
        return "OpenCloseFilter"
    }
    
    override func buildProgram() throws {
        switch _op {
        case .open:
            _program = try Program.create(fragmentSourcePath: "DilationFragmentShader")
            _program2 = try Program.create(fragmentSourcePath: "ErosionFragmentShader")
            
        case .close:
            _program = try Program.create(fragmentSourcePath: "ErosionFragmentShader")
            _program2 = try Program.create(fragmentSourcePath: "DilationFragmentShader")
            
        default:
            fatalError()
        }
    }
    
    override func setUniformAttributs(context ctx: Context) {
        super.setUniformAttributs(context: ctx)
        
        let texelWidth = 1 / GLfloat(ctx.inputWidth)
        let texelHeight = 1 / GLfloat(ctx.inputHeight)
        _program.setUniform(name: kXOffset, value: texelWidth)
        _program.setUniform(name: kYOffset, value: texelHeight)
        _program.setUniform(name: "radius", value: _radius)
    }
    
    override func setUniformAttributs2(context ctx: Context) {
        super.setUniformAttributs2(context: ctx)
        
        let texelWidth = 1 / GLfloat(ctx.inputWidth)
        let texelHeight = 1 / GLfloat(ctx.inputHeight)
        _program2.setUniform(name: kXOffset, value: texelWidth)
        _program2.setUniform(name: kYOffset, value: texelHeight)
        _program2.setUniform(name: "radius", value: _radius)
    }
}
