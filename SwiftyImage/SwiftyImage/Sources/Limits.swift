//
//  Limits.swift
//  SwiftyImage
//
//  Created by tqtifnypmb on 16/12/2016.
//  Copyright © 2016 tqitfnypmb. All rights reserved.
//

import Foundation
import OpenGLES.ES3.gl
import OpenGLES.ES3.glext

struct Limits {
    
    static var max_varying_components: Int = {
        precondition(EAGLContext.current() != nil)
        
        var count: GLint = 0
        glGetIntegerv(GLenum(GL_MAX_VARYING_COMPONENTS), &count)
        return Int(count)
    }()
}