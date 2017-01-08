//
//  CameraPreviewView.swift
//  SwiftyImage
//
//  Created by tqtifnypmb on 04/01/2017.
//  Copyright © 2017 tqitfnypmb. All rights reserved.
//

import UIKit
import CoreMedia
import OpenGLES.ES3.gl
import OpenGLES.ES3.glext

class CameraPreviewView: UIView, PreviewView {
    
    weak var _program: Program!
    
    override var layer: CALayer {
        return CAEAGLLayer()
    }
    
    func apply(context ctx: Context) throws {
        fatalError()
    }
    
    func bindAttributes(context: Context) {
        let attr = [kVertexPositionAttribute, kTextureCoorAttribute]
        _program.bind(attributes: attr)
    }
    
    func setUniformAttributs(context: Context) {
        _program.setUniform(name: kFirstInputSampler, value: GLint(0))
    }
    
    func buildProgram() throws {
        _program = try ProgramObjectsCacher.shared.program(vertexShaderSrc: "PassthroughVertexShader", fragmentShaderSrc: "SingleInputFragmentShader")
    }
    
    func feedDataAndDraw(context ctx: Context, program: Program) throws {
        var vbo: GLuint = 0
        glGenBuffers(1, &vbo)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), vbo)
        
        var attributes = kVertices
        attributes.append(contentsOf: ctx.textCoor)
        attributes.withUnsafeBytes { bytes in
            glBufferData(GLenum(GL_ARRAY_BUFFER), bytes.count, bytes.baseAddress, GLenum(GL_STATIC_DRAW))
        }
        glVertexAttribPointer(program.location(ofAttribute: kVertexPositionAttribute), 2, GLenum(GL_FLOAT), GLboolean(GL_FALSE), 0, nil)
        glEnableVertexAttribArray(program.location(ofAttribute: kVertexPositionAttribute))
        
        kVertices.withUnsafeBytes { bytes in
            let offset = UnsafeRawPointer(bitPattern: bytes.count)
            glVertexAttribPointer(program.location(ofAttribute: kTextureCoorAttribute), 2, GLenum(GL_FLOAT), GLboolean(GL_FALSE), 0, offset)
            glEnableVertexAttribArray(program.location(ofAttribute: kTextureCoorAttribute))
        }
        
        ctx.activateInput()
        glClearColor(0.0, 0.0, 0.0, 1.0);
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT));
        glDrawArrays(GLenum(GL_TRIANGLE_STRIP), 0, 4)
        
        glDeleteBuffers(1, &vbo)
    }
    
    func applyToFrame(context ctx: Context, inputFrameBuffer: InputFrameBuffer, time: CMTime, next: @escaping (Context, InputFrameBuffer) throws -> Void) throws {
        ctx.frameSerialQueue.async {[weak self] in
            guard let strong_self = self else { return }
            do {
                ctx.setInput(input: inputFrameBuffer)
                
                let layer = strong_self.layer as! CAEAGLLayer
                let outputFrameBuffer = EAGLOutputFrameBuffer(eaglLayer: layer)
                ctx.setOutput(output: outputFrameBuffer)
                
                try strong_self.buildProgram()
                strong_self.bindAttributes(context: ctx)
                try strong_self._program.link()
                ctx.setCurrent(program: strong_self._program)
                strong_self.setUniformAttributs(context: ctx)
                
                try strong_self.feedDataAndDraw(context: ctx, program: strong_self._program)
                
                ProgramObjectsCacher.shared.release(program: strong_self._program)
                strong_self._program = nil
                
            } catch {
                fatalError(error.localizedDescription)
            }
        }
    }
}
