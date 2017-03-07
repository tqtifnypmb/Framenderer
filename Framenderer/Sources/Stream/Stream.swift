//
//  Stream.swift
//  Framenderer
//
//  Created by tqtifnypmb on 07/03/2017.
//  Copyright © 2017 tqtifnypmb. All rights reserved.
//

import Foundation

public protocol Stream {
    /// Filters that are going to be applied to the data from Camera
    var filters: [Filter] {get set}
    
    func start()
    func stop()
}
