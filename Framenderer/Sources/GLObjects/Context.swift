//
//  Context.swift
//  Framenderer
//
//  Created by tqtifnypmb on 08/12/2016.
//  Copyright © 2016 tqitfnypmb. All rights reserved.
//

import CoreGraphics
import Foundation
import OpenGLES.ES3.gl
import OpenGLES.ES3.glext
import AVFoundation

public class Context {
    private let _context: EAGLContext
    static let _shareGroup: EAGLSharegroup = EAGLSharegroup()
    private var _input: InputFrameBuffer?
    private var _output: OutputFrameBuffer?
    
    var enableInputOutputToggle = true
    
    var frameSerialQueue: DispatchQueue = {
        return DispatchQueue(label: "com.github.Framenderer.frameSerialQueue")
    }()
    
    var audioSerialQueue: DispatchQueue = {
        return DispatchQueue(label: "com.github.Framenderer.audioSerialQueue")
    }()
    
    init() {
        _context = EAGLContext(api: .openGLES3, sharegroup: Context._shareGroup)
    }
    
    func setAsCurrent() {
        if _context != EAGLContext.current() {
            EAGLContext.setCurrent(_context)
        }
    }
    
    func setCurrent(program: Program) {
        program.use()
    }
    
    func setInput(input: InputFrameBuffer) {
        _input = input
    }
    
    func setOutput(output: OutputFrameBuffer) {
        _output = output
    }
    
    func activateOutput() throws {
        try _output?.useAsOutput()
    }
    
    func activateInput() {
        _input?.useAsInput()
    }
    
    func processedImage() -> CGImage? {
        return _output?.convertToImage()
    }
    
    func toggleInputOutputIfNeeded() {
        if enableInputOutputToggle && _output != nil && _input != nil {
            let input = _output?.convertToInput(bitmapInfo: _input!.bitmapInfo)
            _input = input
        }
    }
    
    func reset() {
        _input = nil;
        _output = nil;
    }
    
    var inputWidth: GLsizei {
        return _input!.width
    }
    
    var inputHeight: GLsizei {
        return _input!.height
    }
    
    var inputFormat: GLenum {
        return _input!.format
    }
    
    var inputBitmapInfo: CGBitmapInfo {
        return _input!.bitmapInfo
    }
    
    var outputFrameBuffer: OutputFrameBuffer? {
        return self._output
    }
    
    var textCoor: [GLfloat] {
        return _input!.textCoor
    }
    
    var eaglContext: EAGLContext {
        return _context
    }
    
    var audioCaptureOutput: AVCaptureOutput?
    var videoCaptureOutput: AVCaptureOutput?
}
