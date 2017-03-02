//
//  OutputFrameBuffer.swift
//  Framenderer
//
//  Created by tqtifnypmb on 04/01/2017.
//  Copyright © 2017 tqitfnypmb. All rights reserved.
//

import CoreGraphics

protocol OutputFrameBuffer {
    func useAsOutput() throws
    func convertToImage() -> CGImage?
    func convertToInput(bitmapInfo: CGBitmapInfo) -> InputFrameBuffer
}
