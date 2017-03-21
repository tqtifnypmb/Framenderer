//
//  AdaptiveThresholdFilter.swift
//  Framenderer
//
//  Created by tqtifnypmb on 20/03/2017.
//  Copyright © 2017 tqtifnypmb. All rights reserved.
//

import Foundation

public class AdaptiveThresholdFilter: BaseFilter {
    public enum Method: Int {
        case mean = 0
        case gaussian = 1
    }
    
    private let _max: Float
    private let _radius: Int
    private let _method: Method
    private let _type: ThresholdType
    public init(max: Float, radius: Int, method: Method, type: ThresholdType) {
        _max = max
        _radius = radius
        _method = method
        _type = type
    }
    
    override public var name: String {
        return "AdaptiveThresholdFilter"
    }
    
    override func buildProgram() throws {
        _program = try Program.create(fragmentSourcePath: "AdaptiveThresholdFragmentShader")
    }
    
    override func setUniformAttributs(context ctx: Context) {
        super.setUniformAttributs(context: ctx)
        
        let texelWidth = 1 / GLfloat(ctx.inputWidth)
        let texelHeight = 1 / GLfloat(ctx.inputHeight)
        _program.setUniform(name: kXOffset, value: texelWidth)
        _program.setUniform(name: kYOffset, value: texelHeight)
        
        _program.setUniform(name: "radius", value: Float(_radius))
        
        let sigma = 0.3 * Double(_radius - 1) + 0.8
        _program.setUniform(name: "sigma", value: Float(sigma))
        _program.setUniform(name: "method", value: _method.rawValue)
        _program.setUniform(name: "type", value: _type.rawValue)
        _program.setUniform(name: "max", value: _max)
    }
}
