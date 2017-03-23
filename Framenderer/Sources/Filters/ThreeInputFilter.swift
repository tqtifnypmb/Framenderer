//
//  ThreeInputFilter.swift
//  Framenderer
//
//  Created by tqtifnypmb on 29/01/2017.
//  Copyright © 2017 tqitfnypmb. All rights reserved.
//

import Foundation
import CoreGraphics
import OpenGLES.ES3.gl
import OpenGLES.ES3.glext
import CoreMedia

open class ThreeInputFilter: DualInputFilter {
    
    private var _thirdSource: CGImage?
    private var _thirdInputFrameBuffer: InputFrameBuffer?
    
    override init() {
        super.init()
    }
    
    init(thirdInput: CGImage) {
        _thirdSource = thirdInput
        
        super.init()
    }
    
    init(secondInput: CGImage, thirdInput: CGImage) {
        _thirdSource = thirdInput
        
        super.init(secondInput: secondInput)
    }
    
    override func setUniformAttributs(context: Context) {
        super.setUniformAttributs(context: context)
        _program.setUniform(name: kThirdInputSampler, value: GLint(2))
    }
    
    override public func apply(context ctx: Context) throws {
        glActiveTexture(GLenum(GL_TEXTURE2))
        let blendingInput = try ImageInputFrameBuffer(image: _thirdSource!)
        blendingInput.useAsInput()
        
        try super.apply(context: ctx)
    }
    
    override public func applyToFrame(context ctx: Context, inputFrameBuffer: InputFrameBuffer, presentationTimeStamp time: CMTime, next: @escaping (Context, InputFrameBuffer) throws -> Void) throws {
        if _thirdSource != nil && _thirdInputFrameBuffer == nil {
            _thirdInputFrameBuffer = try ImageInputFrameBuffer(image: _thirdSource!)
            
            glActiveTexture(GLenum(GL_TEXTURE2))
            _thirdInputFrameBuffer?.useAsInput()
        } else if _thirdInputFrameBuffer == nil {
            _thirdInputFrameBuffer = inputFrameBuffer
            
            glActiveTexture(GLenum(GL_TEXTURE2))
            _thirdInputFrameBuffer?.useAsInput()
            return      // wait for next frame
        }
        
        try super.applyToFrame(context: ctx, inputFrameBuffer: inputFrameBuffer, presentationTimeStamp: time) {[weak self] ctx2, input2 in
            self?._thirdInputFrameBuffer = nil
            try next(ctx2, input2)
        }
    }
}
