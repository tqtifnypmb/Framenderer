//
//  Filter.swift
//  Framenderer
//
//  Created by tqtifnypmb on 08/12/2016.
//  Copyright © 2016 tqitfnypmb. All rights reserved.
//

import OpenGLES.ES3.gl
import OpenGLES.ES3.glext
import CoreMedia
import AVFoundation

// common shader attribute/uniform/sampler name
let kVertexPositionAttribute = "vPosition"      // vertex position attribute name
let kTextureCoorAttribute = "vTextCoor"         // texture coordinate attribute name
let kFirstInputSampler = "firstInput"           // texture sampler name for single input program
let kSecondInputSampler = "secondInput"         // texture sampler name for second input of dual input program
let kThirdInputSampler = "thirdInput"           // texture sampler name for the third input of three input program
let kTexelWidth = "texelWidth"                  // texture element width uniform name
let kTexelHeight = "texelHeight"                // texture element height uniform name
let kXOffset = "xOffset"                        // uniform name for horizontal offset
let kYOffset = "yOffset"                        // uniform name for vertical offset

// vertex data
let kVertices: [GLfloat] = [
                                -1.0, -1.0,
                                -1.0,  1.0,
                                 1.0, -1.0,
                                 1.0,  1.0,
                           ]

public enum ContentScaleMode {
    case scaleToFill
    case aspectFit
    case aspectFill
}

public protocol Filter {
    var name: String { get }
    var contentScaleMode: ContentScaleMode { get set }
    
    func apply(context: Context) throws
    func applyToFrame(context: Context, inputFrameBuffer: InputFrameBuffer, presentationTimeStamp: CMTime, next: @escaping (_ context: Context, _ inputFrameBuffer: InputFrameBuffer) throws -> Void) throws
    
    func applyToAudio(context: Context, sampleBuffer: CMSampleBuffer, next: @escaping (_ context: Context, _ sampleBuffer: CMSampleBuffer) throws -> Void) throws
}
