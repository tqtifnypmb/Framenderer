//
//  ComponentExchangeFilter.swift
//  SwiftyImage
//
//  Created by tqtifnypmb on 18/02/2017.
//  Copyright © 2017 tqtifnypmb. All rights reserved.
//

import Foundation

public class ComponentExchangeFilter: BaseFilter {
    public enum Mode {
        case rgb_bgr_32
    }
    
    private let _mode: Mode
    public init(mode: Mode) {
        _mode = mode
    }
    
    override func buildProgram() throws {
        switch _mode {
        case .rgb_bgr_32:
            _program = try Program.create(fragmentSourcePath: "RGB2BGRExchangeFragmentShader")
        }
    }
    
    override public var name: String {
        return "ComponentExchangeFilter"
    }
}
