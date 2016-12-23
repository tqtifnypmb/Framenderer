//
//  BaseCamera.swift
//  SwiftyImage
//
//  Created by tqtifnypmb on 22/12/2016.
//  Copyright © 2016 tqitfnypmb. All rights reserved.
//

import Foundation
import AVFoundation

class BaseCamera: NSObject, Camera {
    var filters: [Filter] = []
    var output: CameraOutput!
    
    private let _captureSession: AVCaptureSession
    private let _cameraFrameSerialQueue: DispatchQueue
    
    init(captureSession: AVCaptureSession) {
        _captureSession = captureSession
        _cameraFrameSerialQueue = DispatchQueue(label: "com.github.SwityImage.CameraSerial")
    }
    
    func captureInput() -> AVCaptureInput {
        fatalError()
    }
    
    func startRunning() {
        guard !_captureSession.isRunning else { return }
        
        let ctx = Context()
        ctx.setAsCurrent()
        //let inputFrameBuffer = try FrameBuffer(texture: _origin.cgImage!, rotation: .none)
        //ctx.setInput(input: inputFrameBuffer)
        
        #if DEBUG
            ProgramObjectsCacher.shared.check_finish()
        #endif
        
        let output = AVCaptureVideoDataOutput()
        output.setSampleBufferDelegate(self, queue: _cameraFrameSerialQueue)
        assert(_captureSession.canAddOutput(output))
        _captureSession.addOutput(output)
        
        let input = captureInput()
        assert(_captureSession.canAddInput(input))
        _captureSession.addInput(input)
        
        _captureSession.startRunning()
    }
    
    func stopRunning() {
        guard _captureSession.isRunning else { return }
    }
    
    func takePhoto() {
        guard _captureSession.isRunning else { return }
    }
}

extension BaseCamera: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
        
    }
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didDrop sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
        
    }
}
