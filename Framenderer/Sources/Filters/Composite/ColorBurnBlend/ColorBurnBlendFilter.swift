//
//  ColorBurnBlendFilter.swift
//  Framenderer
//
//  Created by tqtifnypmb on 15/12/2016.
//  Copyright © 2016 tqitfnypmb. All rights reserved.
//

import Foundation
import CoreGraphics

public class ColorBurnBlendFilter: DualInputFilter {
    
    public init(otherImage: CGImage) {
        super.init(secondInput: otherImage)
    }
    
    override func buildProgram() throws {
        _program = try Program.create(fragmentSourcePath: "ColorBurnBlendFragmentShader")
    }
    
    override public var name: String {
        return "ColorBurnBlendFilter"
    }
}
