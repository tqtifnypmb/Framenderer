//
//  MorphologyFilter.swift
//  Framenderer
//
//  Created by tqtifnypmb on 23/03/2017.
//  Copyright © 2017 tqtifnypmb. All rights reserved.
//

import Foundation
import CoreMedia

public class Morphology: Filter {
    
    public enum Operation {
        case open
        case close
        case gradient
        case tophat
        case blackhat
    }
    
    private let _imp: Filter
    public init(operation: Operation, radius: Int = 1) {
        switch operation {
        case .open:
            fallthrough
        case .close:
            _imp = OpenCloseFilter(radius: radius, operation: operation)
            
        case .gradient:
            _imp = GradientFilter(radius: radius)
            
        case .tophat:
            fatalError()
            
        case .blackhat:
            fatalError()
        }
    }
    
    public var name: String {
        return "Morphology"
    }
    
    public func apply(context: Context) throws {
        try _imp.apply(context: context)
    }
    
    public func applyToFrame(context: Context, inputFrameBuffer: InputFrameBuffer, presentationTimeStamp: CMTime, next: @escaping (_ context: Context, _ inputFrameBuffer: InputFrameBuffer) throws -> Void) throws {
        try _imp.applyToFrame(context: context, inputFrameBuffer: inputFrameBuffer, presentationTimeStamp: presentationTimeStamp, next: next)
    }
    
    public func applyToAudio(context: Context, sampleBuffer: CMSampleBuffer, next: @escaping (_ context: Context, _ sampleBuffer: CMSampleBuffer) throws -> Void) throws {
        try _imp.applyToAudio(context: context, sampleBuffer: sampleBuffer, next: next)
    }
}
