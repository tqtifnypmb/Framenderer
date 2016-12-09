//
//  Canvas.swift
//  SwiftyImage
//
//  Created by tqtifnypmb on 08/12/2016.
//  Copyright © 2016 tqitfnypmb. All rights reserved.
//

import Foundation

protocol Canvas {
    var filters: [Filter] {get set}
    
    func processAsync(_ onCompletion: (_ isFinished: Bool) -> Void)
    func process() throws
}
