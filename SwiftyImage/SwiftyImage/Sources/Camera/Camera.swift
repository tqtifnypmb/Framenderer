//
//  Camera.swift
//  SwiftyImage
//
//  Created by tqtifnypmb on 22/12/2016.
//  Copyright © 2016 tqitfnypmb. All rights reserved.
//

import Foundation

protocol Camera {
    var filters: [Filter] {get set}
    
    func startRunning()
    func stopRunning()
    func takePhoto()
}
