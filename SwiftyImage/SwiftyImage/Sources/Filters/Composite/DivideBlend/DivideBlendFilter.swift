//
//  DivideBlendFilter.swift
//  SwiftyImage
//
//  Created by tqtifnypmb on 14/12/2016.
//  Copyright © 2016 tqitfnypmb. All rights reserved.
//

import Foundation
import CoreGraphics

class DivideBlendFilter: DualInputFilter {

    /**
     init a [Divide blend](https://en.wikipedia.org/wiki/Blend_modes) filter
     
        if asDivisor
            result = canvas / _otherImage_
        else
            result = _otherImage_ / canvas
     
     - parameter otherImage: specifies a other image
     */
    init(otherImage: CGImage, asDivisor: Bool = false) {
        _asDivisor = asDivisor
        
        super.init(secondInput: otherImage)
    }
    private let _asDivisor: Bool
    
    
    override func buildProgram() throws {
        _program = try Program.create(fragmentSourcePath: "DivideBlendFragmentShader")
    }
    
    override func setUniformAttributs(context: Context) {
        super.setUniformAttributs(context: context)
        
        _program.setUniform(name: "isDivisor", value: _asDivisor)
    }
}
