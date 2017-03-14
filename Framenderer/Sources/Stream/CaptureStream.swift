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

open class CaptureStream: BaseStream, AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureAudioDataOutputSampleBufferDelegate {
    public var previewView: PreviewView? {
        set {
            _previewView = newValue
        }
        
        get {
            return _previewView
        }
    }
    
    private let _frameSerialQueue: DispatchQueue
    private let _session: AVCaptureSession
    
    public init(session: AVCaptureSession, positon: AVCaptureDevicePosition) {
        _session = session
        _frameSerialQueue = DispatchQueue(label: "com.github.Framenderer.CameraSerial")
        
        super.init()
        
        _isFront = positon == .front
        _guessRotation = true
        _allowDropFrameIfNeeded = true
    }
    
    public override func start() {
        guard !_session.isRunning else { return }
        
        _ctx = Context()
        _ctx.enableInputOutputToggle = false
        let video = AVCaptureVideoDataOutput()
        video.alwaysDiscardsLateVideoFrames = false
        video.setSampleBufferDelegate(self, queue: _frameSerialQueue)
        //
        //        for format in output.availableVideoCVPixelFormatTypes as! [NSNumber] {
        //            kCMPixelFormat_422YpCbCr8_yuvs
        //        }
        video.videoSettings = [kCVPixelBufferPixelFormatTypeKey as AnyHashable : kCVPixelFormatType_32BGRA]
        assert(_session.canAddOutput(video))
        _session.addOutput(video)
        
        let audio = AVCaptureAudioDataOutput()
        audio.setSampleBufferDelegate(self, queue: _frameSerialQueue)
        assert(_session.canAddOutput(audio))
        _session.addOutput(audio)
        
        _ctx.audioCaptureOutput = audio
        _ctx.videoCaptureOutput = video
        
        let input = cameraInput()
        assert(_session.canAddInput(input))
        _session.addInput(input)
        
        if let device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeAudio) {
            let input = try! AVCaptureDeviceInput(device: device)
            assert(_session.canAddInput(input))
            _session.addInput(input)
        }
        _session.startRunning()
    }
    
    public override func stop() {
        guard _session.isRunning else { return }
        
        _session.stopRunning()
    }
    
    func cameraInput() -> AVCaptureInput {
        if let devices = AVCaptureDevice.devices(withMediaType: AVMediaTypeVideo) as? [AVCaptureDevice] {
            let position: AVCaptureDevicePosition = _isFront ? .front : .back
            for d in devices {
                if d.position == position {
                    let input = try! AVCaptureDeviceInput(device: d)
                    return input
                }
            }
        }
        
        fatalError("No available capture device")
    }
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate & AVCaptureAudioDataOutpuSampleBufferDelegate

extension CaptureStream {
    public func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
        let isVideo = captureOutput is AVCaptureVideoDataOutput
        
        if isVideo {
            guard self.canFeed() else { return }
            _ctx.frameSerialQueue.async {[retainedBuffer = sampleBuffer, weak self] in
                do {
                    try self?.feed(videoBuffer: retainedBuffer!)
                } catch {
                    fatalError(error.localizedDescription)
                }
            }
        } else {
            _ctx.audioSerialQueue.async {[retainedBuffer = sampleBuffer, weak self] in
                do {
                    try self?.feed(audioBuffer: retainedBuffer!)
                } catch {
                    fatalError(error.localizedDescription)
                }
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
