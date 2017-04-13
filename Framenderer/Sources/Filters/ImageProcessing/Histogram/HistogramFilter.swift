//
//  HistogramFilter.swift
//  Framenderer
//
//  Created by tqtifnypmb on 12/04/2017.
//  Copyright © 2017 tqtifnypmb. All rights reserved.
//

import Foundation
import CoreMedia

public class HistogramFilter: Filter {
    public enum HistogramType {
        case luminance
        case red
        case blue
        case green
    }
    
    private var _rawData: [GLubyte]?
    private var _histogram: [GLubyte]?
    private var _program: Program!
    private let _type: HistogramType
    public init(type: HistogramType = .luminance) {
        _type = type
    }
    
    public var name: String {
        return "HistogramFilter"
    }
    
    func bindAttributes(context: Context) {
        let attr = [kVertexPositionAttribute]
        _program.bind(attributes: attr)
    }
    
    func setUniformAttributs(context: Context) {}
    
    func buildProgram() throws {
        switch _type {
        case .luminance:
            _program = try Program.create(vertexSourcePath: "HistogramVertexShader_gray", fragmentSourcePath: "HistogramFragmentShader")
            
        case .red:
            _program = try Program.create(vertexSourcePath: "HistogramVertexShader_red", fragmentSourcePath: "HistogramFragmentShader")
            
        case .green:
            _program = try Program.create(vertexSourcePath: "HistogramVertexShader_green", fragmentSourcePath: "HistogramFragmentShader")
            
        case .blue:
            _program = try Program.create(vertexSourcePath: "HistogramVertexShader_blue", fragmentSourcePath: "HistogramFragmentShader")
        }
    }
    
    deinit {
        if _program != nil {
            ProgramObjectsCacher.shared.release(program: _program)
            _program = nil
        }
    }
    
    func feedDataAndDraw(context ctx: Context, program: Program) throws {
        guard let rawData = _rawData else {
            throw DataError.bufferData(errorDesc: "Can't retrieve buffer data")
        }
        
        var vbo: GLuint = 0
        glGenBuffers(1, &vbo)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), vbo)
        
        rawData.withUnsafeBytes { bytes in
            glBufferData(GLenum(GL_ARRAY_BUFFER), bytes.count, bytes.baseAddress, GLenum(GL_STATIC_DRAW))
        }
        
        glVertexAttribPointer(program.location(ofAttribute: kVertexPositionAttribute),
                              4,
                              GLenum(GL_UNSIGNED_BYTE),
                              GLboolean(GL_FALSE),
                              0,
                              nil)
        glEnableVertexAttribArray(program.location(ofAttribute: kVertexPositionAttribute))
        
        try ctx.activateOutput()
        
        glClearColor(0.0, 0.0, 0.0, 1.0);
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT));
        
        glEnable(GLenum(GL_BLEND))
        glBlendEquation(GLenum(GL_FUNC_ADD))
        glBlendFunc(GLenum(GL_ONE), GLenum(GL_ONE))
        
        glDrawArrays(GLenum(GL_POINTS), 0, ctx.inputWidth * ctx.inputHeight)
        
        glDisable(GLenum(GL_BLEND))
        glDeleteBuffers(1, &vbo)
    }
    
    public func apply(context ctx: Context) throws {
        do {
            glActiveTexture(GLenum(GL_TEXTURE0))

            let oldOutput = ctx.outputFrameBuffer
            if let output = oldOutput {
                _rawData = output.retrieveRawData()
            } else {
                //TODO: read image data from input frame buffer
                fatalError()
            }
            
            if _program == nil {
                try buildProgram()
                bindAttributes(context: ctx)
                try _program.link()
                ctx.setCurrent(program: _program)
                setUniformAttributs(context: ctx)
            } else {
                ctx.setCurrent(program: _program)
            }
            
            let outputFrameBuffer = try TextureOutputFrameBuffer(width: ctx.inputWidth, height: ctx.inputHeight, format: ctx.inputFormat)
            ctx.setOutput(output: outputFrameBuffer)
            try feedDataAndDraw(context: ctx, program: _program)
            
//            _histogram = outputFrameBuffer.retrieveRawData()
//            print(_histogram?.prefix(100))

//            if let output = oldOutput {
//                ctx.setOutput(output: output)
//            }
        } catch {
            throw FilterError.filterError(name: self.name, error: error.localizedDescription)
        }
    }
    
    public func applyToFrame(context ctx: Context, inputFrameBuffer: InputFrameBuffer, presentationTimeStamp: CMTime, next: @escaping (Context, InputFrameBuffer) throws -> Void) throws {
        ctx.setAsCurrent()
        try apply(context: ctx)
        try next(ctx, inputFrameBuffer)
    }
    
    public func applyToAudio(context: Context, sampleBuffer: CMSampleBuffer, next: @escaping (Context, CMSampleBuffer) throws -> Void) throws {
        try next(context, sampleBuffer)
    }
}
