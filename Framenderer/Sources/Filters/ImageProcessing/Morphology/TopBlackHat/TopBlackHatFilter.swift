//
//  TopHatFilter.swift
//  Framenderer
//
//  Created by tqtifnypmb on 23/03/2017.
//  Copyright © 2017 tqtifnypmb. All rights reserved.
//

import Foundation

class TopBlackHatFilter: TwoPassFilter {
    
    private let _radius: Int
    private var _src: InputFrameBuffer!
    
    private let _opt: MorphologyFilter.Operation
    init(radius: Int, operation: MorphologyFilter.Operation) {
        _radius = radius
        _opt = operation
    }
    
    override public var name: String {
        return "TopBlackHatFilter"
    }
    
    override func buildProgram() throws {
        switch _opt {
        case .tophat:
            _program = try Program.create(fragmentSourcePath: "DilationFragmentShader")
            _program2 = try Program.create(fragmentSourcePath: "TopHatFragmentShader")
            
        case .blackhat:
            _program = try Program.create(fragmentSourcePath: "ErosionFragmentShader")
            _program2 = try Program.create(fragmentSourcePath: "BlackHatFragmentShader")
            
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
        super.setUniformAttributs(context: ctx)
        
        let texelWidth = 1 / GLfloat(ctx.inputWidth)
        let texelHeight = 1 / GLfloat(ctx.inputHeight)
        _program2.setUniform(name: kXOffset, value: texelWidth)
        _program2.setUniform(name: kYOffset, value: texelHeight)
        _program2.setUniform(name: "radius", value: _radius)
        
        _program2.setUniform(name: kSecondInputSampler, value: GLint(2))
    }
    
    override func prepareSecondPass(context: Context) throws {
        try super.prepareSecondPass(context: context)
        
        glActiveTexture(GLenum(GL_TEXTURE2))
        _src.useAsInput()
    }
    
    override func apply(context: Context) throws {
        _src = context.inputFrameBuffer
        try super.apply(context: context)
        _src = nil
    }
}
