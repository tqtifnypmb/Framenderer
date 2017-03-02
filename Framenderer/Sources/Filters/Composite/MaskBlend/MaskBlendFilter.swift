//
//  MaskBlendFilter.swift
//  Framenderer
//
//  Created by tqtifnypmb on 29/01/2017.
//  Copyright © 2017 tqitfnypmb. All rights reserved.
//

import UIKit

public class MaskBlendFilter: ThreeInputFilter {
    init(otherImage: CGImage, mask: CGImage) {
        super.init(secondInput: otherImage, thirdInput: mask)
    }
    
    override func buildProgram() throws {
        _program = try Program.create(fragmentSourcePath: "MaskBlendFragmentShader")
    }
    
    override public var name: String {
        return "MaskBlendFilter"
    }
}
