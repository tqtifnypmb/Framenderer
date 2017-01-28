//
//  HueBlendFilter.swift
//  SwiftyImage
//
//  Created by tqtifnypmb on 29/01/2017.
//  Copyright © 2017 tqitfnypmb. All rights reserved.
//

import UIKit

class HueBlendFilter: DualInputFilter {
    init(otherImage: CGImage) {
        super.init(secondInput: otherImage)
    }
    
    override func buildProgram() throws {
        _program = try Program.create(fragmentSourcePath: "HueBlendFragmentShader")
    }
    
    override var name: String {
        return "HueBlendFilter"
    }
}
