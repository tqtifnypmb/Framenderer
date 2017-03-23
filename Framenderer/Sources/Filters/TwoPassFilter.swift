//
//  TwoPassFilter.swift
//  Framenderer
//
//  Created by tqtifnypmb on 11/12/2016.
//  Copyright © 2016 tqitfnypmb. All rights reserved.
//

import Foundation
import OpenGLES.ES3.gl
import OpenGLES.ES3.glext

open class TwoPassFilter: BaseFilter {
    var _program2: Program!
    private var _isProgram2Setup = false
    
    func bindAttributes2(context: Context) {
        let attr = [kVertexPositionAttribute, kTextureCoorAttribute]
        _program2.bind(attributes: attr)
    }
    
    func setUniformAttributs2(context: Context) {
         _program2.setUniform(name: kFirstInputSampler, value: GLint(1))
    }
    
    deinit {
        if _program2 != nil {
            ProgramObjectsCacher.shared.release(program: _program2)
            _program2 = nil
        }
    }

    func prepareSecondPass(context: Context) throws {}
    
    override public func apply(context ctx: Context) throws {
        try super.apply(context: ctx)
        
        do {
            try prepareSecondPass(context: ctx)
            
            glActiveTexture(GLenum(GL_TEXTURE1))
            
            // enable input/output toggle, in case disbaled by frame stream
            let old = ctx.enableInputOutputToggle
            ctx.enableInputOutputToggle = true
            ctx.toggleInputOutputIfNeeded()
            ctx.enableInputOutputToggle = old
            
            if !_isProgram2Setup {
                _isProgram2Setup = true
                
                bindAttributes2(context: ctx)
                try _program2.link()
                ctx.setCurrent(program: _program2)
                setUniformAttributs2(context: ctx)
            } else {
                ctx.setCurrent(program: _program2)
            }
            
            try feedDataAndDraw(context: ctx, program: _program2)
        } catch {
            throw FilterError.filterError(name: self.name, error: error.localizedDescription)
        }
    }
}
