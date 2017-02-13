//
//  LinearBurnBlendFilter.swift
//  SwiftyImage
//
//  Created by tqtifnypmb on 15/12/2016.
//  Copyright © 2016 tqitfnypmb. All rights reserved.
//

import Foundation
import CoreGraphics

class LinearBurnBlendFilter: DualInputFilter {
    
    init(otherImage: CGImage) {
        super.init(secondInput: otherImage)
    }
    
    override func buildProgram() throws {
        _program = try Program.create(fragmentSourcePath: "LinearBurnBlendFragmentShader")
    }
    
    override var name: String {
        return "LinearBurnBlendFilter"
    }
}
