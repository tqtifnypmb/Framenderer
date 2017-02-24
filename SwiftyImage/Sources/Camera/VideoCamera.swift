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
    
    public init(outputURL url: URL, width: Int32, height: Int32, quality: Quality = .high, fileType type: String = AVFileTypeMPEG4, codecType: CMVideoCodecType = kCMVideoCodecType_MPEG4Video, cameraPosition: AVCaptureDevicePosition = .back) throws {
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
        
        var descp: CMVideoFormatDescription?
        if noErr != CMVideoFormatDescriptionCreate(nil, codecType, width, height, nil, &descp) {
            throw AVAssetSettingsError.assetWriter(errorDessc: "Incompatible arguments")
        }
        
        let input = AVAssetWriterInput(mediaType: AVMediaTypeVideo, outputSettings: nil, sourceFormatHint: descp)
        
        // Only if fast texture is not supported, we need to use the CVPixelBufferPool of 
        // AVAssetWriterInputPixelBufferAdaptor
        let sourceAttrs: [String: Any] = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA,
                           kCVPixelBufferWidthKey as String: width,
                           kCVPixelBufferHeightKey as String: height,
                           kCVPixelBufferOpenGLCompatibilityKey as String: true,
                           kCVPixelBufferIOSurfacePropertiesKey as String: [:]]
        
        let adaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: input, sourcePixelBufferAttributes: sourceAttrs)
        _frameWriter = FrameWriter(writer: adaptor)
        _outputWriter.add(input)
        
        super.init(captureSession: session, cameraPosition: cameraPosition)
    }
    
    public func startRecording() {
        guard !_isRecording else { return }
        _isRecording = true
        
        _outputWriter.startWriting()
        _outputWriter.startSession(atSourceTime: kCMTimeZero)
        filters.append(_frameWriter)
    }
    
    public func finishRecording(completionHandler handler: (() -> Void)?) {
        guard _isRecording else { return }
        _isRecording = false
        
        if let idx = filters.index(where: { $0 is FrameWriter }) {
            filters.remove(at: idx)
        }
        
        _outputWriter.finishWriting {
            handler?()
        }
    }
}
