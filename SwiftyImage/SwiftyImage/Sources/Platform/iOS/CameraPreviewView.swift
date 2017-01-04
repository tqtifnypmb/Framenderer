//
//  CameraPreviewView.swift
//  SwiftyImage
//
//  Created by tqtifnypmb on 04/01/2017.
//  Copyright © 2017 tqitfnypmb. All rights reserved.
//

import UIKit
import CoreMedia

class CameraPreviewView: UIView, PreviewView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    override var layer: CALayer {
        return CAEAGLLayer()
    }
    
    func apply(context ctx: Context) throws {
        ctx.toggleInputOutputIfNeeded()
        let layer = self.layer as! CAEAGLLayer
        let outputFrameBuffer = EAGLOutputFrameBuffer(eaglLayer: layer)
        
        ctx.setOutput(output: outputFrameBuffer)
    }
    
    func applyToFrame(context: Context, sampleBuffer: CMSampleBuffer, time: CMTime, next: @escaping (Context) throws -> Void) throws {
        
    }
    
    
}
