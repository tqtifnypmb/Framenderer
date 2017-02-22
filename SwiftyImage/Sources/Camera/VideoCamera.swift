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
        case auto
        case low
        case medium
        case high
    }
    
    private let _outputWriter: AVAssetWriter
    private let _input: AVAssetWriterInput
    
    private var _isRecording: Bool = false
    
    public init(outputURL url: URL, fileType type: String = AVFileTypeMPEG4, quality: Quality = .auto, cameraPosition: AVCaptureDevicePosition = .back) throws {
        precondition(url.isFileURL)

        let session = AVCaptureSession()
        session.beginConfiguration()
        
        switch quality {
        case .low:
            session.sessionPreset = AVCaptureSessionPresetLow
            
        case .medium:
            session.sessionPreset = AVCaptureSessionPresetMedium
            
        case .high:
            session.sessionPreset = AVCaptureSessionPresetHigh
            
        case .auto:
            // TODO choose base on network connection type
            session.sessionPreset = AVCaptureSessionPresetLow
        }
        
        session.commitConfiguration()
        
        _outputWriter = try AVAssetWriter(outputURL: url, fileType: type)
        _input = AVAssetWriterInput(mediaType: type, outputSettings: nil)
        _outputWriter.add(_input)
        
        super.init(captureSession: session, cameraPosition: cameraPosition)
    }
    
    override var isInterestInCookedInput: Bool {
        return _isRecording
    }
    
    public func resumeRecording() {
        _isRecording = true
    }
    
    public func stopRecording() {
        _isRecording = false
    }
    
    public func finishRecording(completionHandler handler: @escaping () -> Void) {
        _isRecording = false
        _outputWriter.finishWriting(completionHandler: handler)
    }
    
    override func cookedCameraInput(sampleBuffer: CMSampleBuffer) {
        guard _isRecording else { return }
        
    }
}
