//
//  HueAdjustFilter.swift
//  SwiftyImage
//
//  Created by tqtifnypmb on 29/01/2017.
//  Copyright © 2017 tqitfnypmb. All rights reserved.
//

import UIKit

class HueAdjustFilter: BaseFilter {
    init(angle: Float = 0.0) {
        _angle = angle
    }
    private let _angle: GLfloat
    
    override func buildProgram() throws {
        _program = try Program.create(fragmentSourcePath: "HueAdjustFragmentShader")
    }
    
    override func setUniformAttributs(context: Context) {
        super.setUniformAttributs(context: context)
        
        _program.setUniform(name: "angle", value: _angle)
    }
    
    override var name: String {
        return "HueAdjustFilter"
    }
}
