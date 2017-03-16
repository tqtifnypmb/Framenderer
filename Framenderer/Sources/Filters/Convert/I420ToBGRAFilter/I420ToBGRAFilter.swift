//
//  I420ToBGRAFilter.swift
//  Framenderer
//
//  Created by tqtifnypmb on 16/03/2017.
//  Copyright © 2017 tqtifnypmb. All rights reserved.
//

import Foundation

public class I420ToBGRAFilter: ThreeInputFilter {
    override func buildProgram() throws {
        _program = try Program.create(fragmentSourcePath: "I420ToBGRAFragmentShader")
    }
    
    override public var name: String {
        return "I420ToBGRAFilter"
    }
}
