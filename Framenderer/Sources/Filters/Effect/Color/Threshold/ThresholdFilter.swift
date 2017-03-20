//
//  Threshold.swift
//  Framenderer
//
//  Created by tqtifnypmb on 20/03/2017.
//  Copyright © 2017 tqtifnypmb. All rights reserved.
//

import Foundation

public enum ThresholdType: Int {
    case binary = 0
    case binary_inverse = 1
    case truncate = 2
    case to_zero = 3
    case to_zero_inverse = 4
}

public class ThresholdFilter: BaseFilter {
    private let _thresh: Float
    private let _max: Float
    private let _type: ThresholdType
    public init(thresh: Float, max: Float, type: ThresholdType) {
        precondition(thresh >= 0.0 && thresh <= 1.0)
        precondition(max >= 0.0 && max <= 1.0)
        
        _thresh = thresh
        _max = max
        _type = type
    }
    
    override public var name: String {
        return "ThresholdFilter"
    }
    
    override func buildProgram() throws {
        _program = try Program.create(fragmentSourcePath: "ThresholdFragmentShader")
    }
    
    override func setUniformAttributs(context ctx: Context) {
        super.setUniformAttributs(context: ctx)
        
        _program.setUniform(name: "threshold", value: _thresh)
        _program.setUniform(name: "maxValue", value: _max)
        _program.setUniform(name: "type", value: _type.rawValue)
    }
}
