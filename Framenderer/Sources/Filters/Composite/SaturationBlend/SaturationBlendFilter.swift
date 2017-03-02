//
//  SaturationBlendFilter.swift
//  Framenderer
//
//  Created by tqtifnypmb on 28/01/2017.
//  Copyright © 2017 tqitfnypmb. All rights reserved.
//

import UIKit

public class SaturationBlendFilter: DualInputFilter {
    public init(otherImage: CGImage) {
        super.init(secondInput: otherImage)
    }
    
    override func buildProgram() throws {
        _program = try Program.create(fragmentSourcePath: "SaturationBlendFragmentShader")
    }
    
    override public var name: String {
        return "SaturationBlendFilter"
    }
}
