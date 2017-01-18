//
//  BaseBlendFilter.swift
//  SwiftyImage
//
//  Created by tqtifnypmb on 14/12/2016.
//  Copyright © 2016 tqitfnypmb. All rights reserved.
//

import Foundation
import CoreGraphics
import OpenGLES.ES3.gl
import OpenGLES.ES3.glext
import CoreMedia

public class DualInputFilter: BaseFilter {
    
    private let _secondSource: CGImage
    private var _firstFrameTimeStamp: CMTime?
    private var _firstFrameBuffer: InputFrameBuffer?
    private var _secondFramebuffer: InputFrameBuffer?
    
    init(secondInput: CGImage) {
        _secondSource = secondInput
    }
    
    override func setUniformAttributs(context: Context) {
        super.setUniformAttributs(context: context)
        _program.setUniform(name: kSecondInputSampler, value: GLint(1))
    }
    
    override func apply(context ctx: Context) throws {
        glActiveTexture(GLenum(GL_TEXTURE1))
        let blendingInput = try ImageInputFrameBuffer(image: _secondSource)
        blendingInput.useAsInput()
        
        glActiveTexture(GLenum(GL_TEXTURE0))
        try super.apply(context: ctx)
    }
    
    override func applyToFrame(context ctx: Context, inputFrameBuffer: InputFrameBuffer, time: CMTime, next: @escaping (Context, InputFrameBuffer) throws -> Void) throws {
        if _firstFrameTimeStamp == nil {
            glActiveTexture(GLenum(GL_TEXTURE0))
            _firstFrameTimeStamp = time
            _firstFrameBuffer = inputFrameBuffer
        } else if _secondFramebuffer == nil && CMTimeCompare(_firstFrameTimeStamp!, time) < 0 {
            glActiveTexture(GLenum(GL_TEXTURE1))
            _secondFramebuffer = inputFrameBuffer
            _secondFramebuffer?.useAsInput()
            
            glActiveTexture(GLenum(GL_TEXTURE0))
            ctx.setInput(input: _firstFrameBuffer!)
            try super.apply(context: ctx)
            
            let result = ctx.outputFrameBuffer!.convertToInput(bitmapInfo: _firstFrameBuffer!.bitmapInfo)
            
            _firstFrameBuffer = nil
            _secondFramebuffer = nil
            _firstFrameTimeStamp = nil
            
            try next(ctx, result)
        } else {
            throw DataError.disorderFrame(errorDesc: "Frame disorder")
        }
    }
}
