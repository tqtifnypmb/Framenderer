//
//  BaseCamera.swift
//  SwiftyImage
//
//  Created by tqtifnypmb on 22/12/2016.
//  Copyright © 2016 tqitfnypmb. All rights reserved.
//

import Foundation
import AVFoundation

open class BaseCamera: NSObject, Camera, AVCaptureVideoDataOutputSampleBufferDelegate {
    public var filters: [Filter] = []
    public var previewView: PreviewView!
    
    var _ctx: Context!
    var _additionalFilter: Filter?
    
    private let _captureSession: AVCaptureSession
    private let _cameraFrameSerialQueue: DispatchQueue
    private let _cameraPosition: AVCaptureDevicePosition
    private let _renderSemaphore: DispatchSemaphore!
    private var _isFullRangeYUV = true
    
    init(captureSession: AVCaptureSession, cameraPosition: AVCaptureDevicePosition) {
        _captureSession = captureSession
        _cameraPosition = cameraPosition
        _cameraFrameSerialQueue = DispatchQueue(label: "com.github.SwityImage.CameraSerial")
        _renderSemaphore = DispatchSemaphore(value: 1)
    }
    
    public func startRunning() {
        guard !_captureSession.isRunning else { return }
        
        precondition(previewView != nil)
        
        _ctx = Context()
        _ctx.enableInputOutputToggle = false
        let output = AVCaptureVideoDataOutput()
        output.alwaysDiscardsLateVideoFrames = false
        output.setSampleBufferDelegate(self, queue: _cameraFrameSerialQueue)
//        
//        for format in output.availableVideoCVPixelFormatTypes as! [NSNumber] {
//            kCMPixelFormat_422YpCbCr8_yuvs
//        }
        output.videoSettings = [kCVPixelBufferPixelFormatTypeKey as AnyHashable : kCVPixelFormatType_32BGRA]
        
        assert(_captureSession.canAddOutput(output))
        _captureSession.addOutput(output)
        
        let input = cameraInput()
        assert(_captureSession.canAddInput(input))
        _captureSession.addInput(input)
        
        _captureSession.startRunning()
    }
    
    public func stopRunning() {
        guard _captureSession.isRunning else { return }
        
        _captureSession.stopRunning()
    }
    
    func cameraInput() -> AVCaptureInput {
        if let devices = AVCaptureDevice.devices(withMediaType: AVMediaTypeVideo) as? [AVCaptureDevice] {
            for d in devices {
                if d.position == _cameraPosition {
                    let input = try! AVCaptureDeviceInput(device: d)
                    return input
                }
            }
        }
        
        fatalError("No available capture device")
    }
    
    // MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
    
    public func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
        if case .timedOut = _renderSemaphore.wait(timeout: DispatchTime.now()) {
            return
        }
        
        _ctx.frameSerialQueue.async {[retainedBuffer = sampleBuffer, weak self] in
            guard let strong_self = self else { return }
                        
            do {
                strong_self._ctx.setAsCurrent()
                let time: CMTime = CMSampleBufferGetPresentationTimeStamp(retainedBuffer!)
                
                var currentFilters = strong_self.filters
                if let addition = strong_self._additionalFilter {
                    currentFilters.append(addition)
                }
                currentFilters.append(strong_self.previewView)
                
                let starter = currentFilters.removeFirst()
                
                // ref: http://wiki.haskell.org/Continuation
                var continuation: ((Context, InputFrameBuffer) throws -> Void)!
                continuation = {[weak self] ctx, input in
                    guard let strong_self = self else { return }
                    
                    if !currentFilters.isEmpty {
                        let filter = currentFilters.removeFirst()
                        try filter.applyToFrame(context: ctx, inputFrameBuffer: input, presentationTimeStamp: time, next: continuation)
                    } else {
                        ctx.reset()
                        strong_self._renderSemaphore.signal()
                        continuation = nil      // break the reference-cycle
                    }
                }
                
                let input = try SMSampleInputFrameBuffer(sampleBuffer: retainedBuffer!, isFont: strong_self._cameraPosition == .front)
                try starter.applyToFrame(context: strong_self._ctx, inputFrameBuffer:input, presentationTimeStamp: time, next: continuation)
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
