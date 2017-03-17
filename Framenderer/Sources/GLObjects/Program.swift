//
//  Program.swift
//  Framenderer
//
//  Created by tqtifnypmb on 08/12/2016.
//  Copyright © 2016 tqitfnypmb. All rights reserved.
//

import Foundation
import CoreGraphics
import OpenGLES.ES3.gl
import OpenGLES.ES3.glext

class Program {
    
    private let _program: GLuint
    private var _attributesMap: [String] = []
    private var _isLinked: Bool = false
    private var _vertexShader: GLuint = 0
    private var _fragmentShader: GLuint = 0
    
    init(vertexSource vSrc: String, fragmentSource fSrc: String) throws {
        _program = glCreateProgram()
        
        _vertexShader = try ProgramObjectsCacher.shared.shader(type: GLenum(GL_VERTEX_SHADER), src: vSrc)
        _fragmentShader = try ProgramObjectsCacher.shared.shader(type: GLenum(GL_FRAGMENT_SHADER), src: fSrc)
        
        glAttachShader(_program, _vertexShader)
        glAttachShader(_program, _fragmentShader)
    }
    
    class func create(vertexSource vSrc: String, fragmentSource fSrc: String) throws -> Program {
        return try ProgramObjectsCacher.shared.program(vertexShaderSrc: vSrc, fragmentShaderSrc: fSrc)
    }
    
    class func create(vertexSourcePath vPath: String, fragmentSourcePath fPath: String) throws -> Program {
        let vSrc = try! String(contentsOfFile: Bundle(for: Program.self).path(forResource: vPath, ofType: "vsh")!)
        let fSrc = try! String(contentsOfFile: Bundle(for: Program.self).path(forResource: fPath, ofType: "fsh")!)
        return try Program.create(vertexSource: vSrc, fragmentSource: fSrc)
    }
    
    class func create(fragmentSourcePath fPath: String) throws -> Program {
        return try Program.create(vertexSourcePath: "PassthroughVertexShader", fragmentSourcePath: fPath)
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
    
    func setUniform(name: String, value: CGPoint) {
        name.withGLcharString { name in
            let loc = glGetUniformLocation(_program, name)
            assert(loc != -1)
            glUniform2f(loc, GLfloat(value.x), GLfloat(value.y))
        }
    }
    
    func setUniform(name: String, value: Bool) {
        name.withGLcharString { name in
            let loc = glGetUniformLocation(_program, name)
            assert(loc != -1)
            glUniform1i(loc, value ? 1 : 0)
        }
    }
    
    func setUniform(name: String, color value: [GLfloat]) {
        precondition(value.count == 4)
        
        name.withGLcharString { name in
            let loc = glGetUniformLocation(_program, name)
            assert(loc != -1)
            glUniform4f(loc, value[0], value[1], value[2], value[3])
        }
    }
    
    func setUniform(name: String, mat3x3 value: [GLfloat]) {
        precondition(value.count == 9)
        
        name.withGLcharString { name in
            let loc = glGetUniformLocation(_program, name)
            assert(loc != -1)
            glUniformMatrix3fv(loc, 1, GLboolean(GL_FALSE), value)
        }
    }
    
    var program: GLuint {
        return _program
    }
    
    deinit {
        ProgramObjectsCacher.shared.release(shader: _vertexShader)
        ProgramObjectsCacher.shared.release(shader: _fragmentShader)
        glDeleteProgram(_program)
    }
    
    func link() throws {
        // since program objects are cached, It's possible for a program
        // to be linked more than once
        guard !_isLinked else { return }
        
        glLinkProgram(_program)
        
        var linkStatus: GLint = 0
        glGetProgramiv(_program, GLenum(GL_LINK_STATUS), &linkStatus)
    
        if linkStatus != GL_TRUE {
            var logs = [GLchar](repeating: 0, count: 512)
            glGetProgramInfoLog(_program, 512, nil, &logs)
            throw GLError.link(infoLog: String.from(GLcharArray: logs))
        }
        _isLinked = true
    }
}
