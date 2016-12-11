//
//  Program.swift
//  SwiftyImage
//
//  Created by tqtifnypmb on 08/12/2016.
//  Copyright © 2016 tqitfnypmb. All rights reserved.
//

import Foundation
import OpenGLES.ES3.gl
import OpenGLES.ES3.glext

class Program {
    
    private let _program: GLuint
    private var _attributesMap: [String] = []
    
    private init(vertexSource vSrc: String, fragmentSource fSrc: String) throws {
        _program = glCreateProgram()
        
        let vShader = try compileShader(type: GLenum(GL_VERTEX_SHADER), source: vSrc)
        let fShader = try compileShader(type: GLenum(GL_FRAGMENT_SHADER), source: fSrc)
        
        glAttachShader(_program, vShader)
        glAttachShader(_program, fShader)
    }
    
    class func create(vertexSource vSrc: String, fragmentSource fSrc: String) throws -> Program {
        return try Program(vertexSource: vSrc, fragmentSource: fSrc)
    }
    
    class func create(vertexSourcePath vPath: String, fragmentSourcePath fPath: String) throws -> Program {
        let vSrc = try! String(contentsOfFile: Bundle.main.path(forResource: vPath, ofType: "vsh")!)
        let fSrc = try! String(contentsOfFile: Bundle.main.path(forResource: fPath, ofType: "fsh")!)
        return try Program.create(vertexSource: vSrc, fragmentSource: fSrc)
    }
    
    func use() {
        glUseProgram(_program)
        glDisable(GLenum(GL_DEPTH_TEST))
    }
    
    func bind(attributes: [String]) {
        // TODO: Check duplicate 
        let start = _attributesMap.count
        for idx in start ..< start + attributes.count {
            let name = attributes[idx - start]
            name.withGLcharString { name in
                glBindAttribLocation(_program, GLuint(idx), name)
            }
        }
        _attributesMap.append(contentsOf: attributes)
    }
    
    func location(ofAttribute name: String) -> GLuint {
        if let idx = _attributesMap.index(of: name) {
            return GLuint(_attributesMap.startIndex.distance(to: idx))
        } else {
            fatalError()
        }
    }
    
    func setUniform(name: String, value: GLint) {
        name.withGLcharString { name in
            let loc = glGetUniformLocation(_program, name)
            assert(loc != -1)
            glUniform1i(loc, value)
        }
    }
    
    func setUniform(name: String, value: GLfloat) {
        name.withGLcharString { name in
            let loc = glGetUniformLocation(_program, name)
            assert(loc != -1)
            glUniform1f(loc, value)
        }
    }
    
    var program: GLuint {
        return _program
    }
    
    deinit {
        glDeleteProgram(_program)
    }
    
    private func compileShader(type: GLenum, source: String) throws -> GLuint {
        let shader = glCreateShader(type)
        
        var cStr = UnsafePointer<GLchar>(source.cString(using: .utf8))
        glShaderSource(shader, 1, &cStr, nil)
        
        glCompileShader(shader)
        
        var compileStatus: GLint = 0
        glGetShaderiv(shader, GLenum(GL_COMPILE_STATUS), &compileStatus)
        if compileStatus != GL_TRUE {
            var logs = [GLchar](repeating: 0, count: 512)
            glGetShaderInfoLog(shader, 512, nil, &logs)
            
            let typeStr = type == GLenum(GL_VERTEX_SHADER) ? "Vertex" : "Fragment"
            throw GLError.compile(type: typeStr, infoLog: String.from(GLcharArray: logs))
        }
        
        return shader
    }
    
    func link() throws {
        glLinkProgram(_program)
        
        var linkStatus: GLint = 0
        glGetProgramiv(_program, GLenum(GL_LINK_STATUS), &linkStatus)
        
        if linkStatus != GL_TRUE {
            var logs = [GLchar](repeating: 0, count: 512)
            glGetProgramInfoLog(_program, 512, nil, &logs)
            throw GLError.link(infoLog: String.from(GLcharArray: logs))
        }
        
        //glDeleteShader(vShader)
        //glDeleteShader(fShader)
    }
}
