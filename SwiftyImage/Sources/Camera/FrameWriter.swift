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
    private var _timeStamp: CMTime?
    private var _presentationTime: CMTime = kCMTimeZero
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
        ctx.setAsCurrent()
        
        if _program == nil {
            try buildProgram()
            bindAttributes(context: ctx)
            try _program.link()
            ctx.setCurrent(program: _program)
            setUniformAttributs(context: ctx)
        } else {
            ctx.setCurrent(program: _program)
        }
        
        ctx.setInput(input: inputFrameBuffer)
        
        var pixelBuffer: CVPixelBuffer?
        if kCVReturnSuccess != CVPixelBufferPoolCreatePixelBuffer(nil, _writer.pixelBufferPool!, &pixelBuffer) {
            throw DataError.pixelBuffer(errorDesc: "Can't create CVPixelBuffer from shared CVPixelBufferPool")
        }
        let outputFrameBuffer = try TextureOutputFrameBuffer(width: ctx.inputWidth, height: ctx.inputHeight, bitmapInfo: inputFrameBuffer.bitmapInfo, pixelBuffer: pixelBuffer)
        ctx.setOutput(output: outputFrameBuffer)
        
        try super.feedDataAndDraw(context: ctx, program: _program)
        
        let timeStamp = calculateTime(with: time)
        if !_writer.append(outputFrameBuffer._renderTarget, withPresentationTime: timeStamp) {
            throw AVAssetError.assetWriter(errorDessc: "Can't append frame at time: \(timeStamp) to output")
        }
        
        try next(ctx, inputFrameBuffer)
    }
    
    private func calculateTime(with time: CMTime) -> CMTime {
        if let lastTime = _timeStamp {
            let duration = CMTimeSubtract(time, lastTime)
            _presentationTime = CMTimeAdd(_presentationTime, duration)
        }
        _timeStamp = time
        return _presentationTime
    }
}
