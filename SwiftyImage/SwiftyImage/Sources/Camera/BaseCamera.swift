//
//  BaseCamera.swift
//  SwiftyImage
//
//  Created by tqtifnypmb on 22/12/2016.
//  Copyright © 2016 tqitfnypmb. All rights reserved.
//

import Foundation
import AVFoundation

class BaseCamera: NSObject, Camera, AVCaptureVideoDataOutputSampleBufferDelegate {
    var filters: [Filter] = []
    var cameraOutputView: CameraOutputView!
    
    private let _captureSession: AVCaptureSession
    private let _cameraFrameSerialQueue: DispatchQueue
    private var _ctx: Context!
    
    init(captureSession: AVCaptureSession) {
        _captureSession = captureSession
        _cameraFrameSerialQueue = DispatchQueue(label: "com.github.SwityImage.CameraSerial")
    }
    
    func captureInput() -> AVCaptureInput {
        fatalError()
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
    
    func takePhoto() {
        guard _captureSession.isRunning else { return }
    }
    
    // MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
        _ctx.frameSerialQueue.async {
            do {
                self._ctx.setAsCurrent()
                
                let inputFrameBuffer = try FrameBuffer(sampleBuffer: sampleBuffer)
                self._ctx.setInput(input: inputFrameBuffer)
                
                let time: CMTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
                
                var currentFilters = self.filters
                let starter = currentFilters.removeFirst()
                
                // ref: http://wiki.haskell.org/Continuation
                var continuation: ((Context) throws -> Void)!
                continuation = { ctx in
                    if !currentFilters.isEmpty {
                        let filter = currentFilters.removeFirst()
                        try filter.applyToFrame(context: ctx, time: time, finishBlock: continuation)
                    } else {
                        #if DEBUG
                            ProgramObjectsCacher.shared.check_finish()
                        #endif
                    }
                }
                
                try starter.applyToFrame(context: self._ctx, time: time, finishBlock: continuation)
            } catch {
                fatalError(error.localizedDescription)
            }
        }
    }
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didDrop sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
        
    }
}
