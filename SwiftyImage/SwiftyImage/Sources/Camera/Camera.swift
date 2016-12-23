//
//  Camera.swift
//  SwiftyImage
//
//  Created by tqtifnypmb on 22/12/2016.
//  Copyright © 2016 tqitfnypmb. All rights reserved.
//

import Foundation

/**
    Data flow:
        Camera --> Filters --> Output
 */
protocol Camera {
    /// Filters that are going to be applied to the data from Camera
    var filters: [Filter] {get set}
    
    /// Sepcifies a view to carry the final result
    var cameraOutputView: CameraOutputView! {get set}
    
    /// Start running the camera
    func startRunning()

    /// Stop camera
    func stopRunning()
    
    /// Take a photo
    func takePhoto()
}

typealias CameraOutputView = Filter
