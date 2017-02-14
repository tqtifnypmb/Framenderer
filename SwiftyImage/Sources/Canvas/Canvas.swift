//
//  Canvas.swift
//  SwiftyImage
//
//  Created by tqtifnypmb on 08/12/2016.
//  Copyright © 2016 tqitfnypmb. All rights reserved.
//

import Foundation

public protocol Canvas {
    /// Filters that are going to be applied to the content of this canvas
    var filters: [Filter] {get set}
    
    /**
        Process asynchrounously.
     
        - parameter onCompletion: Callback whick will be called when process finish
    */
    func processAsync(onCompletion: @escaping (_ isFinished: Bool, _ error: Error?) -> Void)
    
    /// Process synchrounously. Block the calling thread while processing
    func process() throws
}
