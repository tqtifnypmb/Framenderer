//
//  AlphaMaskBlendFilter.swift
//  SwiftyImage
//
//  Created by tqtifnypmb on 29/01/2017.
//  Copyright © 2017 tqitfnypmb. All rights reserved.
//

import Foundation
import CoreImage

public class AlphaMaskBlendFilter: ThreeInputFilter {
    public init(otherImage: CGImage, mask: CGImage) {
        super.init(secondInput: otherImage, thirdInput: mask)
    }
    
    override func buildProgram() throws {
        _program = try Program.create(fragmentSourcePath: "AlphaMaskBlendFragmentShader")
    }
    
    override public var name: String {
        return "AlphaMaskBlendFilter"
    }
}
