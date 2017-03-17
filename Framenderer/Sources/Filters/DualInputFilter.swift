//
//  BaseBlendFilter.swift
//  Framenderer
//
//  Created by tqtifnypmb on 14/12/2016.
//  Copyright © 2016 tqitfnypmb. All rights reserved.
//

import Foundation
import CoreGraphics
import OpenGLES.ES3.gl
import OpenGLES.ES3.glext
import CoreMedia

open class DualInputFilter: BaseFilter {
    
    private var _secondSource: CGImage?
    private var _secondInputFrameBuffer: InputFrameBuffer?
    
    override init() {}
    
    /// create a dual-input fileter with second input
    /// bind to `secondInput`
    init(secondInput: CGImage) {
        _secondSource = secondInput
    }
    
    override func setUniformAttributs(context: Context) {
        super.setUniformAttributs(context: context)
        _program.setUniform(name: kSecondInputSampler, value: GLint(1))
    }
    
    override public func apply(context ctx: Context) throws {
        glActiveTexture(GLenum(GL_TEXTURE1))
        let blendingInput = try ImageInputFrameBuffer(image: _secondSource!)
        blendingInput.useAsInput()
        
        glActiveTexture(GLenum(GL_TEXTURE0))
        try super.apply(context: ctx)
    }
    
    override public func applyToFrame(context ctx: Context, inputFrameBuffer: InputFrameBuffer, presentationTimeStamp time: CMTime, next: @escaping (Context, InputFrameBuffer) throws -> Void) throws {
        if let boundSource = _secondSource {
            _secondInputFrameBuffer = try ImageInputFrameBuffer(image: boundSource)
        } else if _secondInputFrameBuffer == nil {
            _secondInputFrameBuffer = inputFrameBuffer
            return  // wait for next frame
        }
        glActiveTexture(GLenum(GL_TEXTURE1))
        _secondInputFrameBuffer?.useAsInput()
        
        glActiveTexture(GLenum(GL_TEXTURE0))
        ctx.setInput(input: inputFrameBuffer)
        try super.apply(context: ctx)
        
        let result = ctx.outputFrameBuffer!.convertToInput()
        
        if _secondSource == nil {
            _secondInputFrameBuffer = nil
        }
    
        try next(ctx, result)
    }
}
