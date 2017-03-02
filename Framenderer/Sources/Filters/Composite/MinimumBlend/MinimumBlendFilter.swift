//
//  MinimumBlendFilter.swift
//  Framenderer
//
//  Created by tqtifnypmb on 14/12/2016.
//  Copyright © 2016 tqitfnypmb. All rights reserved.
//

import Foundation
import CoreGraphics

public class MinimumBlendFilter: DualInputFilter {
    
    /**
     init a [Minimum blend](https://en.wikipedia.org/wiki/Blend_modes) filter
     
     result = min(canvas, _otherImage_)
     
     - parameter otherImage: specifies a image to be used.
     */
    public init(otherImage: CGImage) {
        super.init(secondInput: otherImage)
    }
    
    override func buildProgram() throws {
        _program = try Program.create(fragmentSourcePath: "MinimumBlendFragmentShader")
    }
    
    override public var name: String {
        return "MinimumBlendFilter"
    }
}
