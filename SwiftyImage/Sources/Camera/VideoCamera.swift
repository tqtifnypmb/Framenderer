//
//  VideoCamera.swift
//  SwiftyImage
//
//  Created by tqtifnypmb on 22/12/2016.
//  Copyright © 2016 tqitfnypmb. All rights reserved.
//

import Foundation
import CoreImage
import AVFoundation

public class VideoCamera: BaseCamera {
    public enum Quality {
        case low
        case medium
        case high
    }
    
    private let _outputWriter: AVAssetWriter
    private let _frameWriter: FrameWriter
    private var _isRecording = false
    private let _outputURL: URL
    
    public init(outputURL url: URL, width: Int32, height: Int32, quality: Quality = .high, fileType type: String = AVFileTypeMPEG4, codecType: String = AVVideoCodecH264, cameraPosition: AVCaptureDevicePosition = .back) throws {
        precondition(url.isFileURL)
        precondition(!FileManager.default.fileExists(atPath: url.relativePath), "File already exists at \(url.relativePath)")
        
        let session = AVCaptureSession()
        session.beginConfiguration()
        
        switch quality {
        case .low:
            session.sessionPreset = AVCaptureSessionPresetLow
            
        case .medium:
            session.sessionPreset = AVCaptureSessionPresetMedium
            
        case .high:
            session.sessionPreset = AVCaptureSessionPresetHigh
        }
        
        session.commitConfiguration()
        
        _outputURL = url
        _outputWriter = try AVAssetWriter(outputURL: url, fileType: type)
        
        let settings: [String: Any] = [AVVideoCodecKey: AVVideoCodecH264,
                                       AVVideoWidthKey: width,
                                       AVVideoHeightKey: height]
        let input = AVAssetWriterInput(mediaType: AVMediaTypeVideo, outputSettings: settings)
        input.expectsMediaDataInRealTime = true
        
        let sourceAttrs: [String: Any] = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA,
                                          kCVPixelBufferWidthKey as String: width,
                                          kCVPixelBufferHeightKey as String: height,
                                          kCVPixelBufferIOSurfacePropertiesKey as String: [:]]
        
        let adaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: input, sourcePixelBufferAttributes: sourceAttrs)
        _frameWriter = FrameWriter(writer: adaptor, width: width, height: height)
        _outputWriter.add(input)
        
        super.init(captureSession: session, cameraPosition: cameraPosition)
    }
    
    public func startRecording() {
        guard !_isRecording else { return }
        _isRecording = true
        
        _outputWriter.startWriting()
        _outputWriter.startSession(atSourceTime: kCMTimeZero)
        _additionalFilter = _frameWriter
    }
    
    public func finishRecording(completionHandler handler: (() -> Void)?) {
        guard _isRecording else { return }
        _isRecording = false
        
        // stop writing ASAP
        _additionalFilter = nil
        
        // stop when current filters-application-cycle finished
        _ctx.frameSerialQueue.async { [weak self] in
            self?._outputWriter.finishWriting {
                handler?()
            }
        }
    }
}
