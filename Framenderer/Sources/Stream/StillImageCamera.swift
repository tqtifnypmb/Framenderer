//
//  StillImageCamera.swift
//  Framenderer
//
//  Created by tqtifnypmb on 22/12/2016.
//  Copyright © 2016 tqitfnypmb. All rights reserved.
//

import Foundation
import AVFoundation

public class StillImageCamera: CaptureStream {
   
    private let _photoOutput: AVCaptureOutput
    var _onComplete: ((_ error: Error?, _ image: CGImage?) -> Void)?
    
    public init(cameraPosition: AVCaptureDevicePosition = .back) {
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
        
        super.init(session: session, positon: cameraPosition)
    }
    
    public func takePhoto(onComplete:@escaping (_ error: Error?, _ image: CGImage?) -> Void) {
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
                    strong_self.stop()
                    
                    strong_self._ctx.frameSerialQueue.sync {
                        do {
                            let result = try strong_self.applyFilters(toSampleBuffer: sampleBufer!)!
                            onComplete(nil, result)
                        } catch {
                            onComplete(error, nil)
                        }
                    }
                }
            })
        }
    }
    
    public override func start() {
        guard !filters.isEmpty || previewView != nil else {
            fatalError("No filter specified")
        }
        super.start()
    }
    
    fileprivate func applyFilters(toSampleBuffer sm: CMSampleBuffer) throws -> CGImage? {
        let data = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sm)!
        let dataProvider = CGDataProvider(data: data as CFData)!
        let captured = CGImage(jpegDataProviderSource: dataProvider, decode: nil, shouldInterpolate: true, intent: CGColorRenderingIntent.defaultIntent)!
        
        _ctx.setAsCurrent()
        _ctx.reset()
        _ctx.enableInputOutputToggle = true
        let inputFrameBuffer = try ImageInputFrameBuffer(image: captured)
        _ctx.setInput(input: inputFrameBuffer)
        
        for filter in filters {
            try filter.apply(context: _ctx)
        }
        
        return _ctx.processedImage()
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
                
                strong_self.stop()
                strong_self._ctx.frameSerialQueue.sync {
                    do {
                        let result = try strong_self.applyFilters(toSampleBuffer: photoSampleBuffer!)
                        strong_self._onComplete?(nil, result)
                    } catch {
                        strong_self._onComplete?(error, nil)
                    }
                    strong_self._onComplete = nil
                }
            }
        }
    }
}
