//
//  RGBToGrayScale.swift
//  Framenderer
//
//  Created by tqtifnypmb on 20/03/2017.
//  Copyright © 2017 tqtifnypmb. All rights reserved.
//

import Foundation

public class RGBToGrayScale: BaseFilter {
    
    override public init() {}
    
    override public var name: String {
        return "RGBToGrayScale"
    }
    
    override func buildProgram() throws {
        _program = try Program.create(fragmentSourcePath: "RGBToGrayScaleFragmentShader")
    }
}
