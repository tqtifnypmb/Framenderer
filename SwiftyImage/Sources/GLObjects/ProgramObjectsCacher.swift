//
//  ProgramObjectsCacher.swift
//  SwiftyImage
//
//  Created by tqtifnypmb on 13/12/2016.
//  Copyright © 2016 tqitfnypmb. All rights reserved.
//

import Foundation
import OpenGLES.ES3.gl
import OpenGLES.ES3.glext

class ProgramObjectsCacher {
    
    static var shared: ProgramObjectsCacher = {
        return ProgramObjectsCacher()
    }()
    
    private var _cachedProgram: [String : (Program, Int)] = [:]
    private var _cachedShader: [String : (GLuint, Int)] = [:]
    
    private init() {}
    
    private func cacheKey(vSrc: String, fSrc: String) -> String {
        return "vSrc:\(vSrc),fSrc:\(fSrc)"
    }
    
    func program(vertexShaderSrc vSrc: String, fragmentShaderSrc fSrc: String) throws -> Program {
        let key = cacheKey(vSrc: vSrc, fSrc: fSrc)
        if let existing = _cachedProgram[key] {
            _cachedProgram[key] = (existing.0, existing.1 + 1)
            return existing.0
        } else {
            let new = try Program(vertexSource: vSrc, fragmentSource: fSrc)
            _cachedProgram[key] = (new, 1)
            return new
        }
    }
    
    private func cacheKey(type: GLenum, src: String) -> String {
        if type == GLenum(GL_VERTEX_SHADER) {
            return "Vertex:\(src)"
        } else {
            return "Fragment:\(src)"
        }
    }
    
    func shader(type: GLenum, src: String) throws -> GLuint {
        let key = cacheKey(type: type, src: src)
        if let existing = _cachedShader[key] {
            _cachedShader[key] = (existing.0, existing.1 + 1)
            return existing.0
        } else {
            let shader = try compileShader(type: type, source: src)
            _cachedShader[key] = (shader, 1)
            return shader
        }
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
    
    func release(program toRelease: Program) {
        for entry in _cachedProgram {
            if entry.value.0.program == toRelease.program {
                let useCount = entry.value.1 - 1
                if useCount == 0 {
                    _cachedProgram.removeValue(forKey: entry.key)
                } else {
                    _cachedProgram[entry.key] = (entry.value.0, useCount)
                }
                break
            }
        }
    }
    
    func release(shader: GLuint) {
        for entry in _cachedShader {
            if entry.value.0 == shader {
                let useCount = entry.value.1 - 1
                if useCount == 0 {
                    glDeleteShader(entry.value.0)
                    _cachedShader.removeValue(forKey: entry.key)
                } else {
                    _cachedShader[entry.key] = (entry.value.0, useCount)
                }
                break
            }
        }
    }
    
    deinit {
        _cachedShader.forEach { entry in
            glDeleteShader(entry.value.0)
        }
    }
    
    #if DEBUG
    func check_finish() {
        assert(_cachedShader.isEmpty)
        assert(_cachedProgram.isEmpty)
    }
    #endif
}
