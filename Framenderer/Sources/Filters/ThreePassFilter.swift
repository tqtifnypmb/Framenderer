//
//  ThreePassFilter.swift
//  Framenderer
//
//  Created by tqtifnypmb on 23/03/2017.
//  Copyright © 2017 tqtifnypmb. All rights reserved.
//

import Foundation

open class ThreePassFilter: TwoPassFilter {
    var _program3: Program!
    private var _isProgram3Setup = false
    
    func bindAttributes3(context: Context) {
        let attr = [kVertexPositionAttribute, kTextureCoorAttribute]
        _program3.bind(attributes: attr)
    }
    
    func setUniformAttributs3(context: Context) {
        _program3.setUniform(name: kFirstInputSampler, value: GLint(2))
    }
    
    func prepareThirdPass(context: Context) throws {}
    
    override public func apply(context ctx: Context) throws {
        try super.apply(context: ctx)
        
        do {
            try prepareThirdPass(context: ctx)
            
            glActiveTexture(GLenum(GL_TEXTURE2))
            
            // enable input/output toggle, in case disbaled by frame stream
            let old = ctx.enableInputOutputToggle
            ctx.enableInputOutputToggle = true
            ctx.toggleInputOutputIfNeeded()
            ctx.enableInputOutputToggle = old
            
            if !_isProgram3Setup {
                _isProgram3Setup = true
                
                bindAttributes3(context: ctx)
                try _program3.link()
                ctx.setCurrent(program: _program3)
                setUniformAttributs3(context: ctx)
            } else {
                ctx.setCurrent(program: _program3)
            }
            
            try feedDataAndDraw(context: ctx, program: _program3)
        } catch {
            throw FilterError.filterError(name: self.name, error: error.localizedDescription)
        }
    }
    
    deinit {
        if _program3 != nil {
            ProgramObjectsCacher.shared.release(program: _program3)
            _program3 = nil
        }
    }
}
