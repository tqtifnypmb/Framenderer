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
    private let _outputWriter: AVAssetWriter
    private var _audioInput: AVAssetWriterInput!
    private var _videoInput: AVAssetWriterInput!
    private let _fileType: String
    private var _audioSampleBufferQueue: [CMSampleBuffer] = []
    private var _writeStarted = false
    
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
        _writeStarted = true
    }
    
    func finishWriting(completionHandler handler: (() -> Void)?) {
        _writeStarted = false
        
        if !_audioSampleBufferQueue.isEmpty {
            _audioInput.requestMediaDataWhenReady(on: DispatchQueue.global(qos: .background), using: { [weak self] in
                guard let strong_self = self else { return }
                
                if strong_self._audioSampleBufferQueue.isEmpty {
                    strong_self._audioInput.markAsFinished()
                    strong_self.doFinishWriting(completionHandler: handler)
                } else {
                    let toAppend = strong_self._audioSampleBufferQueue.removeFirst()
                    strong_self._audioInput.append(toAppend)
                }
            })
        } else {
            doFinishWriting(completionHandler: handler)
        }
    }
    
    private func doFinishWriting(completionHandler handler: (() -> Void)?) {
        _outputWriter.finishWriting {
            handler?()
        }
    }
    
    func prepareAudioInput(sampleBuffer sm: CMSampleBuffer) throws {
        guard _audioInput == nil else { return }
        
        let desc = CMSampleBufferGetFormatDescription(sm)
        _audioInput = AVAssetWriterInput(mediaType: AVMediaTypeAudio, outputSettings: nil, sourceFormatHint: desc)

        if !_outputWriter.canAdd(_audioInput) {
            throw AVAssetError.assetWriter(errorDessc: "Can't audio input")
        }
        
        _outputWriter.add(_audioInput)
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
        
        if _outputWriter.status == .unknown {
            _outputWriter.startWriting()
            _outputWriter.startSession(atSourceTime: time)
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
        let outputFrameBuffer = try TextureOutputFrameBuffer(width: _outputWidth, height: _outputHeight, format: inputFrameBuffer.format, pixelBuffer: pixelBuffer)
        ctx.setOutput(output: outputFrameBuffer)
        
        try super.feedDataAndDraw(context: ctx, program: _program)
        
        if !_writer.append(outputFrameBuffer._renderTarget, withPresentationTime: time) {
            throw AVAssetError.assetWriter(errorDessc: "Can't append frame at time: \(time) to output")
        }
        
        try next(ctx, inputFrameBuffer)
    }
    
    override func applyToAudio(context ctx: Context, sampleBuffer: CMSampleBuffer, next: @escaping (Context, CMSampleBuffer) throws -> Void) throws {
        // Assumption: At least on buffer arrive before write start.
        if _audioInput == nil {
            let captureDataOutput = ctx.audioCaptureOutput as? AVCaptureAudioDataOutput
            let settings = captureDataOutput?.recommendedAudioSettingsForAssetWriter(withOutputFileType: _fileType) as? [String : Any]
            _audioInput = AVAssetWriterInput(mediaType: AVMediaTypeAudio, outputSettings: settings)
            _audioInput.expectsMediaDataInRealTime = true
            
            if !_outputWriter.canAdd(_audioInput) {
                throw AVAssetError.assetWriter(errorDessc: "Can't audio input")
            }
            
            _outputWriter.add(_audioInput)
        }
        
        if !_writeStarted || _outputWriter.status == .unknown {
            try next(ctx, sampleBuffer)
            return
        }
        
        _audioSampleBufferQueue.append(sampleBuffer)
        
        if _audioInput.isReadyForMoreMediaData {
            let toAppend = _audioSampleBufferQueue.removeFirst()
            
            if !_audioInput.append(toAppend) {
                throw AVAssetError.assetWriter(errorDessc: "Can't append audio data")
            }
        }
        
        try next(ctx, sampleBuffer)
    }
}
