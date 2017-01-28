//
//  SaturationBlendFilter.swift
//  SwiftyImage
//
//  Created by tqtifnypmb on 28/01/2017.
//  Copyright © 2017 tqitfnypmb. All rights reserved.
//

import UIKit

class SaturationBlendFilter: DualInputFilter {
    init(otherImage: CGImage) {
        super.init(secondInput: otherImage)
    }
    
    override func buildProgram() throws {
        _program = try Program.create(fragmentSourcePath: "SaturationBlendFragmentShader")
    }
    
    override var name: String {
        return "SaturationBlendFilter"
    }
}
