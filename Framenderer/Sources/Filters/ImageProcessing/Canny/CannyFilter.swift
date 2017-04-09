//
//  CannyFilter.swift
//  Framenderer
//
//  Created by tqtifnypmb on 28/03/2017.
//  Copyright © 2017 tqtifnypmb. All rights reserved.
//

import Foundation

// ref: https://en.wikipedia.org/wiki/Canny_edge_detector

public class CannyFilter: FilterGroup {
    
    private let _blur: Filter
    private let _gradient: Filter
    private let _suppression: Filter
    public init(lowerThresh: Float = 0.0, upperThresh: Float = 1.0, gaussianRadius: Int = 2) {
        if TARGET_IPHONE_SIMULATOR != 0 {       // FIXME
            _blur = MedianBlurFilter()
        } else {
            _blur = GaussianBlurFilter(radius: gaussianRadius)
        }
        _gradient = TaggedGradientFilter()
        _suppression = NonMaxSuppressFilter(lower: lowerThresh, upper: upperThresh, keepAngleInfo: false)
    }
    
    public func expand() -> [Filter] {
        return [_blur, _gradient, _suppression]
    }
}
