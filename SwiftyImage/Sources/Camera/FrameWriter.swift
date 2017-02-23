//
//  FrameWriter.swift
//  SwiftyImage
//
//  Created by tqtifnypmb on 23/02/2017.
//  Copyright © 2017 tqtifnypmb. All rights reserved.
//

import Foundation
import CoreMedia
import AVFoundation

class FrameWriter: BaseFilter {
    
    private let _writer: AVAssetWriterInputPixelBufferAdaptor
    init(writer: AVAssetWriterInputPixelBufferAdaptor) {
        _writer = writer
    }
    
    override func buildProgram() throws {
        _program = try Program.create(fragmentSourcePath: "PassthroughFragmentShader")
    }
    
    override public var name: String {
        return "FrameKeeper"
    }
    
    override func apply(context: Context) throws {
        fatalError("FrameKeeper is not allowed to apply manually")
    }
    
    override func applyToFrame(context ctx: Context, inputFrameBuffer: InputFrameBuffer, time: CMTime, next: @escaping (Context, InputFrameBuffer) throws -> Void) throws {
        if let input = inputFrameBuffer as? TextureInputFrameBuffer, let output = input.originalOutputFrameBuffer as? TextureOutputFrameBuffer, let pixelBuffer = output._renderTarget {
            _writer.append(pixelBuffer, withPresentationTime: time)
        } else {
            fatalError("Not support yet")
        }
        
        try next(ctx, inputFrameBuffer)
    }
}
