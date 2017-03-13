//
//  FrameWriter.swift
//  Framenderer
//
//  Created by tqtifnypmb on 23/02/2017.
//  Copyright © 2017 tqtifnypmb. All rights reserved.
//

import Foundation
import CoreMedia
import AVFoundation

class FrameWriter: BaseFilter {
    
    private let _writer: AVAssetWriterInputPixelBufferAdaptor
    private let _outputWidth: GLsizei
    private let _outputHeight: GLsizei
    private var _timeStamp: CMTime?
    private var _presentationTime: CMTime = kCMTimeZero
    private let _outputWriter: AVAssetWriter
    private var _audioInput: AVAssetWriterInput!
    private let _fileType: String
    
    private var _writeStarted = false
    
    /// Use CMSamplebuffer's presentationTimeStamp as output timestamp
    var respectFrameTimeStamp = false
    
    init(destURL: URL, width: GLsizei, height: GLsizei, type: String, outputSettings settings: [String: Any]?) throws {
        _outputWriter = try AVAssetWriter(url: destURL, fileType: type)
        _fileType = type
        
        let input = AVAssetWriterInput(mediaType: AVMediaTypeVideo, outputSettings: settings)
        input.expectsMediaDataInRealTime = true
        _outputWriter.add(input)
        
        let sourceAttrs: [String: Any] = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA,
                                          kCVPixelBufferWidthKey as String: width,
                                          kCVPixelBufferHeightKey as String: height,
                                          kCVPixelBufferIOSurfacePropertiesKey as String: [:]]
        
        let adaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: input, sourcePixelBufferAttributes: sourceAttrs)
        
        _writer = adaptor
        _outputWidth = width
        _outputHeight = height
    }
    
    convenience init(destURL: URL, type: String, width: GLsizei, height: GLsizei) throws {
        let settings: [String: Any] = [AVVideoCodecKey: AVVideoCodecH264,
                                       AVVideoWidthKey: width,
                                       AVVideoHeightKey: height]
        
        try self.init(destURL: destURL, width: width, height: height, type: type, outputSettings: settings)
    }
    
    func startWriting() {
        _outputWriter.startWriting()
        _outputWriter.startSession(atSourceTime: kCMTimeZero)
        _writeStarted = true
    }
    
    func finishWriting(completionHandler handler: (() -> Void)?) {
        _writeStarted = false
        _outputWriter.finishWriting {
            handler?()
        }
    }
    
    override func buildProgram() throws {
        _program = try Program.create(fragmentSourcePath: "PassthroughFragmentShader")
    }
    
    override public var name: String {
        return "FrameWriter"
    }
    
    override func apply(context: Context) throws {
        fatalError("FrameKeeper is not allowed to apply manually")
    }
    
    override func applyToFrame(context ctx: Context, inputFrameBuffer: InputFrameBuffer, presentationTimeStamp time: CMTime, next: @escaping (Context, InputFrameBuffer) throws -> Void) throws {
        if !_writeStarted {
            try next(ctx, inputFrameBuffer)
            return
        }
        
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
        let outputFrameBuffer = try TextureOutputFrameBuffer(width: _outputWidth, height: _outputHeight, bitmapInfo: inputFrameBuffer.bitmapInfo, pixelBuffer: pixelBuffer)
        ctx.setOutput(output: outputFrameBuffer)
        
        try super.feedDataAndDraw(context: ctx, program: _program)
        
        let timeStamp = calculateTime(with: time)
        if !_writer.append(outputFrameBuffer._renderTarget, withPresentationTime: timeStamp) {
            throw AVAssetError.assetWriter(errorDessc: "Can't append frame at time: \(timeStamp) to output")
        }
        
        try next(ctx, inputFrameBuffer)
    }
    
    override func applyToAudio(context: Context, sampleBuffer: CMSampleBuffer, audioCaptureOutput: AVCaptureAudioDataOutput, next: @escaping (Context, CMSampleBuffer, AVCaptureAudioDataOutput) throws -> Void) throws {
        if _audioInput == nil {
            let audioSettings = audioCaptureOutput.recommendedAudioSettingsForAssetWriter(withOutputFileType: _fileType)
            _audioInput = AVAssetWriterInput(mediaType: AVMediaTypeAudio, outputSettings: audioSettings as! [String : Any]?)
            _audioInput.expectsMediaDataInRealTime = true
            
            assert(_outputWriter.canAdd(_audioInput))
            _outputWriter.add(_audioInput)
        }
        
        if !_writeStarted {
            try next(context, sampleBuffer, audioCaptureOutput)
            return
        }
        
        _audioInput.append(sampleBuffer)
        
        try next(context, sampleBuffer, audioCaptureOutput)
    }
    
    private func calculateTime(with time: CMTime) -> CMTime {
        if respectFrameTimeStamp {
            return time
        }
        
        if let lastTime = _timeStamp {
            let duration = CMTimeSubtract(time, lastTime)
            _presentationTime = CMTimeAdd(_presentationTime, duration)
        }
        _timeStamp = time
        return _presentationTime
    }
}
