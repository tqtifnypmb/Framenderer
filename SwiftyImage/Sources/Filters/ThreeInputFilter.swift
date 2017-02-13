//
//  ThreeInputFilter.swift
//  SwiftyImage
//
//  Created by tqtifnypmb on 29/01/2017.
//  Copyright © 2017 tqitfnypmb. All rights reserved.
//

import Foundation
import CoreGraphics
import OpenGLES.ES3.gl
import OpenGLES.ES3.glext
import CoreMedia

public class ThreeInputFilter: DualInputFilter {
    
    private let _thirdSource: CGImage
    private var _firstInputFrameBuffer: InputFrameBuffer?
    
    init(secondInput: CGImage, thirdInput: CGImage) {
        _thirdSource = thirdInput
        
        super.init(secondInput: secondInput)
    }
    
    override func setUniformAttributs(context: Context) {
        super.setUniformAttributs(context: context)
        _program.setUniform(name: kThirdInputSampler, value: GLint(2))
    }
    
    override func apply(context ctx: Context) throws {
        glActiveTexture(GLenum(GL_TEXTURE2))
        let blendingInput = try ImageInputFrameBuffer(image: _thirdSource)
        blendingInput.useAsInput()
        
        try super.apply(context: ctx)
    }
    
    override func applyToFrame(context ctx: Context, inputFrameBuffer: InputFrameBuffer, time: CMTime, next: @escaping (Context, InputFrameBuffer) throws -> Void) throws {
        glActiveTexture(GLenum(GL_TEXTURE2))
        if _firstInputFrameBuffer == nil {
            _firstInputFrameBuffer = try ImageInputFrameBuffer(image: _thirdSource)
        }
        _firstInputFrameBuffer?.useAsInput()
        
        glActiveTexture(GLenum(GL_TEXTURE0))
        ctx.setInput(input: inputFrameBuffer)
        try super.apply(context: ctx)
        
        let result = ctx.outputFrameBuffer!.convertToInput(bitmapInfo: inputFrameBuffer.bitmapInfo)
        try next(ctx, result)
    }
}
