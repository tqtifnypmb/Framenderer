//
//  VideoCamera.swift
//  SwiftyImage
//
//  Created by tqtifnypmb on 22/12/2016.
//  Copyright © 2016 tqitfnypmb. All rights reserved.
//

import Foundation

class VideoCamera: Camera {
    var filters: [Filter] = []
    var cameraOutputView: CameraOutputView!
    
    func startRunning() {
        
    }
    
    func stopRunning() {
        
    }
    
    func takePhoto() {
        fatalError()
    }
}
