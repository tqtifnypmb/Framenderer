//
//  I420ToBGRAFilter.swift
//  Framenderer
//
//  Created by tqtifnypmb on 16/03/2017.
//  Copyright © 2017 tqtifnypmb. All rights reserved.
//

import Foundation
import CoreMedia
public class I420ToBGRAFilter: DualInputFilter {
    private let _bt601: [GLfloat] = [1, 1, 1,
                                    0, -0.39465, 2.03211,
                                    1.13983, -0.58060, 0]
    
    private let _bt709: [GLfloat] = [1, 1, 1,
                                    0, -0.21482, 2.12798,
                                    1.28033, -0.38059, 0]
    
    override func buildProgram() throws {
        _program = try Program.create(fragmentSourcePath: "I420ToBGRAFragmentShader")
    }
    
    override public var name: String {
        return "I420ToBGRAFilter"
    }
    
    override func setUniformAttributs(context: Context) {
        super.setUniformAttributs(context: context)
        
        _program.setUniform(name: "transform", mat3x3: _bt709)
    }
    
    override public func apply(context: Context) throws {
        fatalError()
    }
}
