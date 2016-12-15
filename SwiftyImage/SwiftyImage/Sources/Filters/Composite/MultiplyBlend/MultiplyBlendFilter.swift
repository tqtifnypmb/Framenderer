//
//  MultiplyBlendFilter.swift
//  SwiftyImage
//
//  Created by tqtifnypmb on 14/12/2016.
//  Copyright © 2016 tqitfnypmb. All rights reserved.
//

import Foundation
import CoreGraphics

class MultiplyBlendFilter: DualInputFilter {
    
    /**
     init a [Multiply blend](https://en.wikipedia.org/wiki/Blend_modes) filter
     
     result = canvas * _otherImage_
     
     - parameter otherImage: specifies a image to multiply with content of the applied convas.
     */
    init(otherImage: CGImage) {
        super.init(secondInput: otherImage)
    }
    
    override func buildProgram() throws {
        _program = try Program.create(fragmentSourcePath: "MultiplyBlendFragmentShader")
    }
}
