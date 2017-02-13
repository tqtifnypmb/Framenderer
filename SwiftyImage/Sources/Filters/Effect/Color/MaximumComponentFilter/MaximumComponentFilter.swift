//
//  MaximumComponentFilter.swift
//  SwiftyImage
//
//  Created by tqtifnypmb on 15/12/2016.
//  Copyright © 2016 tqitfnypmb. All rights reserved.
//

import Foundation

class MaximumComponentFilter: BaseFilter {
    override func buildProgram() throws {
        _program = try Program.create(fragmentSourcePath: "MaximumComponentFragmentShader")
    }
    
    override var name: String {
        return "MaximumComponentFilter"
    }
}
