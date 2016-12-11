//
//  LinearBlending.swift
//  SwiftyImage
//
//  Created by tqtifnypmb on 11/12/2016.
//  Copyright © 2016 tqitfnypmb. All rights reserved.
//

import Foundation
import CoreGraphics
import OpenGLES.ES3.gl
import OpenGLES.ES3.glext

class LinearBlendingFilter: BaseFilter {
    
    let _source: CGImage
    let _a: CGFloat
    init(source: CGImage, a: CGFloat) {
        precondition(a >= 0 && a <= 1)
        
        _source = source
        _a = a
    }
    
    override func setUniformAttributs(context: Context) {
        super.setUniformAttributs(context: context)
        _program.setUniform(name: "a", value: GLfloat(_a))
        _program.setUniform(name: "secondInput", value: GLint(1))
    }
    
    override func buildProgram() throws {
        _program = try Program.create(vertexSourcePath: "PassthroughVertexShader", fragmentSourcePath: "LinearBlendingFragmentShader")
    }
    
    override func apply(context ctx: Context) throws {
        glActiveTexture(GLenum(GL_TEXTURE1))
        let blendingInput = try FrameBuffer(texture: _source)
        blendingInput.useAsInput()
        
        glActiveTexture(GLenum(GL_TEXTURE0))
        try super.apply(context: ctx)
    }
}
