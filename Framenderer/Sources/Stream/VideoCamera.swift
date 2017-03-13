//
//  VideoCamera.swift
//  Framenderer
//
//  Created by tqtifnypmb on 22/12/2016.
//  Copyright © 2016 tqitfnypmb. All rights reserved.
//

import Foundation
import CoreImage
import AVFoundation

public class VideoCamera: CaptureStream {
    public enum Quality {
        case low
        case medium
        case high
    }
    
    private let _frameWriter: FrameWriter
    private var _isRecording = false
    
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
        
        _frameWriter = try FrameWriter(destURL: url, type: type, width: width, height: height)
        _frameWriter.respectFrameTimeStamp = false
        
        super.init(session: session, positon: cameraPosition)
    }
    
    public override func start() {
        guard !filters.isEmpty || previewView != nil else {
            fatalError("No filter specified")
        }
        
        _additionalFilter = _frameWriter
        super.start()
    }
    
    public func startRecording() {
        guard !_isRecording else { return }
        _isRecording = true
        
        _frameWriter.startWriting()
    }
    
    public func finishRecording(completionHandler handler: (() -> Void)?) {
        guard _isRecording else { return }
        _isRecording = false
        
        // stop writing ASAP
        _additionalFilter = nil
        
        // stop when current filters-application-cycle finished
        _ctx.frameSerialQueue.async { [weak self] in
            self?._frameWriter.finishWriting {
                handler?()
            }
        }
    }
}
