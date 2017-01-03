//
//  VideoCamera.swift
//  SwiftyImage
//
//  Created by tqtifnypmb on 22/12/2016.
//  Copyright © 2016 tqitfnypmb. All rights reserved.
//

import Foundation
import CoreImage

class VideoCamera: Camera {
    var filters: [Filter] = []
    var cameraOutputView: CameraOutputView!
    
    func startRunning() {
        
    }
    
    func stopRunning() {
        
    }
    
    func takePhoto(onComplete:@escaping (_ error: Error?, _ image: CGImage?) -> Void) {
        fatalError()
    }
}
