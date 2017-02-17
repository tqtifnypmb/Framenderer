//
//  StillImageCamera.swift
//  SwiftyImage
//
//  Created by tqtifnypmb on 22/12/2016.
//  Copyright © 2016 tqitfnypmb. All rights reserved.
//

import Foundation
import AVFoundation

public class StillImageCamera: BaseCamera {
   
    private let _cameraPosition: AVCaptureDevicePosition
    private let _photoOutput: AVCaptureOutput
    var _onComplete: ((_ error: Error?, _ image: CGImage?) -> Void)?
    
    public init(cameraPosition: AVCaptureDevicePosition) {
        _cameraPosition = cameraPosition
        
        let session = AVCaptureSession()
        session.beginConfiguration()
        session.sessionPreset = AVCaptureSessionPresetPhoto
        session.commitConfiguration()
        
        if #available(iOS 10, *) {
            _photoOutput = AVCapturePhotoOutput()
        } else {
            _photoOutput = AVCaptureStillImageOutput()
        }
        
        session.addOutput(_photoOutput)
        
        super.init(captureSession: session, cameraPosition: cameraPosition)
    }
    
    override func captureInput() -> AVCaptureInput {
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
    
    override public func takePhoto(onComplete:@escaping (_ error: Error?, _ image: CGImage?) -> Void) {
        if #available(iOS 10, *) {
            _onComplete = onComplete
            
            let output = _photoOutput as! AVCapturePhotoOutput
            let settings = AVCapturePhotoSettings(format: nil)
            output.capturePhoto(with: settings, delegate: self)
        } else {
            let output = _photoOutput as! AVCaptureStillImageOutput
            output.captureStillImageAsynchronously(from: _photoOutput.connections.first as? AVCaptureConnection, completionHandler: {[weak self] sampleBufer, error in
                if let error = error {
                    onComplete(error, nil)
                } else {
                    guard let strong_self = self else { return }
                    
                    do {
                        try strong_self.applyFilters(toSampleBuffer: sampleBufer!)
                        
                        let result = strong_self._ctx.processedImage()!
                        onComplete(nil, result)
                    } catch {
                        fatalError(error.localizedDescription)
                    }
                }
            })
        }
    }
    
    func applyFilters(toSampleBuffer sm: CMSampleBuffer) throws {
        _ctx.setAsCurrent()
        let inputFrameBuffer = try SMSampleInputFrameBuffer(sampleBuffer: sm, isFont: _cameraPosition == .front)
        _ctx.setInput(input: inputFrameBuffer)
        
        for filter in filters {
            try filter.apply(context: _ctx)
        }
    }
}

@available(iOS 10, *)
extension StillImageCamera: AVCapturePhotoCaptureDelegate {
    public func capture(_ captureOutput: AVCapturePhotoOutput, didFinishProcessingPhotoSampleBuffer photoSampleBuffer: CMSampleBuffer?, previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
        if let error = error {
            _onComplete?(error, nil)
            _onComplete = nil
        } else {
            DispatchQueue.global(qos: .background).async {[weak self] in
                guard let strong_self = self else { return }
                
                do {
                    try strong_self.applyFilters(toSampleBuffer: photoSampleBuffer!)
                    let result = strong_self._ctx.processedImage()!
                    strong_self._onComplete?(nil, result)
                } catch {
                    fatalError(error.localizedDescription)
                }
                strong_self._onComplete = nil
            }
        }
    }
}
