//
//  Filter.swift
//  SwiftyImage
//
//  Created by tqtifnypmb on 08/12/2016.
//  Copyright © 2016 tqitfnypmb. All rights reserved.
//

import OpenGLES.ES3.gl
import OpenGLES.ES3.glext

// common shader name
let kVertexPositionAttribute = "vPosition"      // vertex position attribute name
let kTextureCoorAttribute = "vTextCoor"         // texture coordinate attribute name
let kFirstInputSampler = "firstInput"           // texture sampler name for single input program
let kSecondInputSampler = "secondInput"         // texture sampler name for second input of dual input program
let kTexelWidth = "texelWidth"                  // texture element width uniform name
let kTexelHeight = "texelHeight"                // texture element height uniform name

let kVertices: [GLfloat] = [
                                -1.0, -1.0,
                                -1.0,  1.0,
                                 1.0, -1.0,
                                 1.0,  1.0,
                           ]

protocol Filter {
    func apply(context: Context) throws
}
