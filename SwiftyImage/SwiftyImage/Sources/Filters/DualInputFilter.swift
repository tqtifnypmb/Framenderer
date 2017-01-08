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
        let blendingInput = try FrameBuffer(texture: _secondSource)
        blendingInput.useAsInput()
        
        glActiveTexture(GLenum(GL_TEXTURE0))
        try super.apply(context: ctx)
    }
    
    override func applyToFrame(context ctx: Context, inputFrameBuffer: InputFrameBuffer, time: CMTime, next: @escaping (Context, InputFrameBuffer) throws -> Void) throws {
        let superApply = super.apply
        ctx.frameSerialQueue.async {[weak self] in
            guard let strong_self = self else { return }
            
            do {
                if strong_self._firstFrameTimeStamp == nil {
                    glActiveTexture(GLenum(GL_TEXTURE0))
                    strong_self._firstFrameTimeStamp = time
                    strong_self._firstFrameBuffer = inputFrameBuffer
                } else if strong_self._secondFramebuffer == nil && CMTimeCompare(strong_self._firstFrameTimeStamp!, time) < 0 {
                    glActiveTexture(GLenum(GL_TEXTURE1))
                    strong_self._secondFramebuffer = inputFrameBuffer
                    strong_self._secondFramebuffer?.useAsInput()
                    
                    glActiveTexture(GLenum(GL_TEXTURE0))
                    ctx.setInput(input: strong_self._firstFrameBuffer!)
                    try superApply(ctx)
                    
                    let result = ctx.outputFrameBuffer!.convertToInput(bitmapInfo: strong_self._firstFrameBuffer!.bitmapInfo)
                    
                    strong_self._firstFrameBuffer = nil
                    strong_self._secondFramebuffer = nil
                    strong_self._firstFrameTimeStamp = nil
                    
                    try next(ctx, result)
                } else {
                    fatalError("Frame disorder")
                }
            } catch {
                fatalError(error.localizedDescription)
            }
        }
    }
}
