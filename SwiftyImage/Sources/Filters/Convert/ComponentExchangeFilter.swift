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
        case bgr_rgb_32
    }
    
    private let _mode: Mode
    public init(mode: Mode) {
        _mode = mode
    }
    
    override func buildProgram() throws {
        switch _mode {
        case .bgr_rgb_32:
            _program = try Program.create(fragmentSourcePath: "BGR2RGBExchangeFragmentShader")
        }
    }
    
    override public var name: String {
        return "ComponentExchangeFilter"
    }
}
