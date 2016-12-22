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
    
    private var _captureSession: AVCaptureSession!
    
    func startRunning() {
        
    }
    
    func stopRunning() {
        
    }
    
    func takePhoto() {
        
    }
}

extension BaseCamera: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
        
    }
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didDrop sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
        
    }
}
