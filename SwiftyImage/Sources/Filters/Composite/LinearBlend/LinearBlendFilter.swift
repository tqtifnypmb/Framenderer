//
//  LinearBlending.swift
//  SwiftyImage
//
//  Created by tqtifnypmb on 11/12/2016.
//  Copyright © 2016 tqitfnypmb. All rights reserved.
//

import Foundation
import CoreGraphics
import OpenGLES.ES3.gl
import OpenGLES.ES3.glext

public class LinearBlendFilter: DualInputFilter {
    
    /**
        init a Linear Blending filter
     
        - parameter source: A image used to blending with content of a canva
        - parameter a: result = source * a + canva * (1 - a)
     */
    public init(source: CGImage, a: CGFloat) {
        precondition(a >= 0 && a <= 1)
        
        _a = a
        super.init(secondInput: source)
    }
    private let _a: CGFloat
    
    override func setUniformAttributs(context: Context) {
        super.setUniformAttributs(context: context)
        _program.setUniform(name: "a", value: GLfloat(_a))
    }
    
    override func buildProgram() throws {
        _program = try Program.create(fragmentSourcePath: "LinearBlendFragmentShader")
    }
    
    override public var name: String {
        return "LinearBlendFilter"
    }
}
