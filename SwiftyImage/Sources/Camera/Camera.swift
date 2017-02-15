//
//  Camera.swift
//  SwiftyImage
//
//  Created by tqtifnypmb on 22/12/2016.
//  Copyright © 2016 tqitfnypmb. All rights reserved.
//

import Foundation
import CoreImage

/**
    Data flow:
        Camera --> Filters --> Output
 */
public protocol Camera {
    /// Filters that are going to be applied to the data from Camera
    var filters: [Filter] {get set}
    
    /// Sepcifies a view to carry the final result
    var previewView: PreviewView! {get set}
    
    /// Start running the camera
    func startRunning()

    /// Stop camera
    func stopRunning()
    
    /// Take a photo
    func takePhoto(onComplete:@escaping (_ error: Error?, _ image: CGImage?) -> Void)
}

public typealias PreviewView = Filter
