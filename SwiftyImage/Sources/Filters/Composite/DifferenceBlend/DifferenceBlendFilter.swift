//
//  DifferenceBlendFilter.swift
//  SwiftyImage
//
//  Created by tqtifnypmb on 14/12/2016.
//  Copyright © 2016 tqitfnypmb. All rights reserved.
//

import Foundation
import CoreGraphics

public class DifferenceBlendShader: DualInputFilter {
    
    /**
     init a [Difference blend](https://en.wikipedia.org/wiki/Blend_modes) filter
     
     result = canvas - _backgroundImage_
     
     - parameter backgroundImage: specifies a bakground image
     */
    public init(otherImage: CGImage) {
        super.init(secondInput: otherImage)
    }
    
    override func buildProgram() throws {
        _program = try Program.create(fragmentSourcePath: "DifferenceBlendFragmentShader")
    }
    
    override public var name: String {
        return "DifferenceBlendShader"
    }
}
