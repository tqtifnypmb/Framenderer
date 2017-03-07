//
//  CaptureStream.swift
//  Framenderer
//
//  Created by tqtifnypmb on 07/03/2017.
//  Copyright © 2017 tqtifnypmb. All rights reserved.
//

import Foundation
import AVFoundation

public typealias PreviewView = Filter

open class CaptureStream: NSObject, Stream, AVCaptureVideoDataOutputSampleBufferDelegate {
    public var filters: [Filter] = []
    
    var _ctx: Context!
    var _additionalFilter: Filter?
    
    public var previewView: PreviewView?
    
    private let _frameSerialQueue: DispatchQueue
    private let _cameraPosition: AVCaptureDevicePosition
    private let _renderSemaphore: DispatchSemaphore!
    private let _session: AVCaptureSession
    public init(session: AVCaptureSession, positon: AVCaptureDevicePosition) {
        _session = session
        _cameraPosition = positon
        _frameSerialQueue = DispatchQueue(label: "com.github.Framenderer.CameraSerial")
        _renderSemaphore = DispatchSemaphore(value: 1)
        
        super.init()
    }
    
    public func start() {
        guard !_session.isRunning else { return }
        
        _ctx = Context()
        _ctx.enableInputOutputToggle = false
        let output = AVCaptureVideoDataOutput()
        output.alwaysDiscardsLateVideoFrames = false
        output.setSampleBufferDelegate(self, queue: _frameSerialQueue)
        //
        //        for format in output.availableVideoCVPixelFormatTypes as! [NSNumber] {
        //            kCMPixelFormat_422YpCbCr8_yuvs
        //        }
        output.videoSettings = [kCVPixelBufferPixelFormatTypeKey as AnyHashable : kCVPixelFormatType_32BGRA]
        
        assert(_session.canAddOutput(output))
        _session.addOutput(output)
        
        let input = cameraInput()
        assert(_session.canAddInput(input))
        _session.addInput(input)
        
        _session.startRunning()
    }
    
    public func stop() {
        guard _session.isRunning else { return }
        
        _session.stopRunning()
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
                
                if let preview = strong_self.previewView {
                    currentFilters.append(preview)
                }
                
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
