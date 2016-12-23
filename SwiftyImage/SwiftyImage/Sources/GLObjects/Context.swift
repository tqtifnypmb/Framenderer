//
//  Context.swift
//  SwiftyImage
//
//  Created by tqtifnypmb on 08/12/2016.
//  Copyright © 2016 tqitfnypmb. All rights reserved.
//

import CoreGraphics
import Foundation
import OpenGLES.ES3.gl
import OpenGLES.ES3.glext

class Context {
    private let _context: EAGLContext
    private static let _shareGroup: EAGLSharegroup = EAGLSharegroup()
    private var _input: FrameBuffer?
    private var _output: FrameBuffer?
    
    var frameSerialQueue: DispatchQueue = {
        return DispatchQueue(label: "com.github.SwiftyImage.ContextSerial")
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
    
    func setInput(input: FrameBuffer) {
        _input = input
    }
    
    func setOutput(output: FrameBuffer) {
        _output = output
        output.useAsOutput()
    }
    
    func activateInput() {
        _input?.useAsInput()
    }
    
    func processedImage() -> CGImage? {
        return _output?.convertToImage()
    }
    
    func toggleInputOutputIfNeeded() {
        if _output != nil && _input != nil {
            _output?.convertToInput(bitmapInfo: _input!.bitmapInfoForInput)
            _input = _output
        }
    }
    
    var inputWidth: GLsizei {
        return _input!.width
    }
    
    var inputHeight: GLsizei {
        return _input!.height
    }
    
    var inputBitmapInfo: CGBitmapInfo {
        return _input!.bitmapInfoForInput
    }
    
    var textCoor: [GLfloat] {
        return _input!.textCoor
    }
}
