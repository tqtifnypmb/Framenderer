//
//  HoughTransformFilter.swift
//  Framenderer
//
//  Created by tqtifnypmb on 02/04/2017.
//  Copyright © 2017 tqtifnypmb. All rights reserved.
//

import Foundation

// ref: https://en.wikipedia.org/wiki/Hough_transform

public class HoughTransformFilter: FilterGroup {
    
    private let _blur: Filter
    private let _gradient: Filter
    private let _suppression: Filter
    private let _accumulator: Filter
    public init(lowerThresh: Float, upperThresh: Float, gaussianRadius: Int = 2) {
        if TARGET_IPHONE_SIMULATOR != 0 {       // FIXME
            _blur = MedianBlurFilter()
        } else {
            _blur = GaussianBlurFilter(radius: gaussianRadius)
        }
        _gradient = TaggedGradientFilter()
        _suppression = NonMaxSuppressFilter(lower: lowerThresh, upper: upperThresh, keepAngleInfo: true)
        
        _accumulator = HoughAccumulatorFilter()
    }
    
    public func expand() -> [Filter] {
        return [_blur, _gradient, _suppression, _accumulator]
    }
}
