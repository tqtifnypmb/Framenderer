//
//  BaseCamera.swift
//  SwiftyImage
//
//  Created by tqtifnypmb on 22/12/2016.
//  Copyright © 2016 tqitfnypmb. All rights reserved.
//

import Foundation
import AVFoundation

public class BaseCamera: NSObject, Camera, AVCaptureVideoDataOutputSampleBufferDelegate {
    var filters: [Filter] = []
    var cameraOutputView: CameraOutputView!
    
    var _ctx: Context!
    
    private let _captureSession: AVCaptureSession
    private let _cameraFrameSerialQueue: DispatchQueue
    
    init(captureSession: AVCaptureSession) {
        _captureSession = captureSession
        _cameraFrameSerialQueue = DispatchQueue(label: "com.github.SwityImage.CameraSerial")
    }
    
    func startRunning() {
        guard !_captureSession.isRunning else { return }
        
        precondition(cameraOutputView != nil)
        
        // output view is just a pass-through filter
        filters.append(cameraOutputView)
        
        _ctx = Context()
        
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
        
        _captureSession.stopRunning()
    }
    
    func takePhoto(onComplete:@escaping (_ error: Error?, _ image: CGImage?) -> Void) {
        fatalError("Called virtual function")
    }
    
    func captureInput() -> AVCaptureInput {
        fatalError("Called virtual function")
    }
    
    // MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
    
    public func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
        _ctx.frameSerialQueue.async {[weak self] in
            guard let strong_self = self else { return }
            
            do {
                strong_self._ctx.setAsCurrent()
                let time: CMTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
                
                var currentFilters = strong_self.filters
                let starter = currentFilters.removeFirst()
                
                // ref: http://wiki.haskell.org/Continuation
                var continuation: ((Context) throws -> Void)!
                continuation = { ctx in
                    if !currentFilters.isEmpty {
                        let filter = currentFilters.removeFirst()
                        try filter.applyToFrame(context: ctx, sampleBuffer: sampleBuffer, time: time, next: continuation)
                    } else {
                        #if DEBUG
                            ProgramObjectsCacher.shared.check_finish()
                        #endif
                    }
                }
                
                try starter.applyToFrame(context: strong_self._ctx, sampleBuffer: sampleBuffer, time: time, next: continuation)
            } catch {
                fatalError(error.localizedDescription)
            }
        }
    }
    
    public func captureOutput(_ captureOutput: AVCaptureOutput!, didDrop sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
        #if DEBUG
            let time = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
            print("[Info] Frame drop [Timestamp: \(time)]")
        #endif
    }
}
