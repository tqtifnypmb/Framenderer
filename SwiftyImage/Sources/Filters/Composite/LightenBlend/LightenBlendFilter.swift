//
//  LightenBlendFilter.swift
//  SwiftyImage
//
//  Created by tqtifnypmb on 14/12/2016.
//  Copyright © 2016 tqitfnypmb. All rights reserved.
//

import Foundation
import CoreGraphics

public class LightenBlendFilter: DualInputFilter {
    
    public init(otherImage: CGImage) {
        super.init(secondInput: otherImage)
    }
    
    override func buildProgram() throws {
        _program = try Program.create(fragmentSourcePath: "LightenBlendFragmentShader")
    }
    
    override public var name: String {
        return "LightenBlendFilter"
    }
}
