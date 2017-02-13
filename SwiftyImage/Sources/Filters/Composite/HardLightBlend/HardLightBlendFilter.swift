//
//  HardLightBlendFilter.swift
//  SwiftyImage
//
//  Created by tqtifnypmb on 15/12/2016.
//  Copyright © 2016 tqitfnypmb. All rights reserved.
//

import Foundation
import CoreGraphics

class HardLightBlendFilter: DualInputFilter {
    
    /**
        init a [HardLight blend](https://en.wikipedia.org/wiki/Blend_modes) filter
        
        equivalent to Overlay, but with the bottom and top images swapped
     
        - parameter otherImage: specifies the foreground image
     */
    init(otherImage: CGImage) {
        super.init(secondInput: otherImage)
    }
    
    override func buildProgram() throws {
        _program = try Program.create(fragmentSourcePath: "HardLightBlendFragmentShader")
    }
    
    override var name: String {
        return "HardLightBlendFilter"
    }
}
