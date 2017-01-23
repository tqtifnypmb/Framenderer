//
//  SubtrachBlendFilter.swift
//  SwiftyImage
//
//  Created by tqtifnypmb on 14/12/2016.
//  Copyright © 2016 tqitfnypmb. All rights reserved.
//

import Foundation
import CoreGraphics

class SubtractBlendFilter: DualInputFilter {
    
    /**
     init a [Subtract blend](https://en.wikipedia.org/wiki/Blend_modes) filter
     
     if asSubtractor
        result = canvas - _otherImage_
     else
        result = _otherImage_ - canvas
     
     - parameter otherImage: specifies a other image
     */
    init(otherImage: CGImage, asSubtractor: Bool = false) {
        _asSubtractor = asSubtractor
        
        super.init(secondInput: otherImage)
    }
    private let _asSubtractor: Bool
    
    override func buildProgram() throws {
        _program = try Program.create(fragmentSourcePath: "SubtractBlendFragmentShader")
    }
    
    override func setUniformAttributs(context: Context) {
        super.setUniformAttributs(context: context)
        
        _program.setUniform(name: "isSubtractor", value: _asSubtractor)
    }
    
    override var name: String {
        return "SubtractBlendFilter"
    }
}
