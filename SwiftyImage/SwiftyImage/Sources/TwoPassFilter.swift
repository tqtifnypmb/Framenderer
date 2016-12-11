//
//  TwoPassFilter.swift
//  SwiftyImage
//
//  Created by tqtifnypmb on 11/12/2016.
//  Copyright © 2016 tqitfnypmb. All rights reserved.
//

import Foundation
import OpenGLES.ES3.gl
import OpenGLES.ES3.glext

class TwoPassFilter: BaseFilter {
    var _program2: Program!
    
    func bindAttributes2(context: Context) {
        let attr = ["vPosition", "vTextCoor"]
        _program2.bind(attributes: attr)
    }
    
    func setUniformAttributs2(context: Context) {
        _program2.setUniform(name: "firstInput", value: GLint(1))
    }
    
    func buildProgram2() throws {
        fatalError("Called Virtual Function")
    }
    
    override func apply(context ctx: Context) throws {
        try super.apply(context: ctx)

        glActiveTexture(GLenum(GL_TEXTURE1))
        ctx.toggleInputOutputIfNeeded()
        
        try buildProgram2()
        bindAttributes2(context: ctx)
        try _program2.link()
        ctx.setCurrent(program: _program2)
        setUniformAttributs2(context: ctx)
        
        feedDataAndDraw(context: ctx, program: _program2)
        
        _program2 = nil
    }
}
