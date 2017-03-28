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
    
    private let _lower: Float
    private let _upper: Float
    private let _radius: Int
    public init(lowerThresh: Float, upperThresh: Float, gaussianRadius: Int = 2) {
        _lower = lowerThresh
        _upper = upperThresh
        _radius = gaussianRadius
    }
    
    public func expand() -> [Filter] {
        let gaussian = GaussianBlurFilter(radius: _radius)
        let gradient = TaggedGradientFilter()
        let nonMaxSuppress = NonMaxSuppressFilter(lower: _lower, upper: _upper)
        return [gaussian, gradient, nonMaxSuppress]
    }
}
