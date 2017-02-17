//
//  VideoCamera.swift
//  SwiftyImage
//
//  Created by tqtifnypmb on 22/12/2016.
//  Copyright © 2016 tqitfnypmb. All rights reserved.
//

import Foundation
import CoreImage

public class VideoCamera: Camera {
    public var filters: [Filter] = []
    public var previewView: PreviewView!
    
    public func startRunning() {
        
    }
    
    public func stopRunning() {
        
    }
    
    public func takePhoto(onComplete:@escaping (_ error: Error?, _ image: CGImage?) -> Void) {
        fatalError()
    }
}
