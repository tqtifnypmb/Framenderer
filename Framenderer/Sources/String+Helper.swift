//
//  String+Helper.swift
//  Framenderer
//
//  Created by tqtifnypmb on 08/12/2016.
//  Copyright © 2016 tqitfnypmb. All rights reserved.
//

import Foundation
import OpenGLES.ES3.gl
import OpenGLES.ES3.glext

extension String {
    
    func withGLcharString(_ block: (UnsafePointer<GLchar>) -> Void) {
        if let cStr = self.cString(using: .utf8) {
            block(UnsafePointer<GLchar>(cStr))
        } else {
            fatalError()
        }
    }
    
    static func from(GLcharArray charArray: [GLchar]) -> String {
        if let ret = String(cString: charArray, encoding: .utf8) {
            return ret
        } else {
            fatalError()
        }
    }
}
