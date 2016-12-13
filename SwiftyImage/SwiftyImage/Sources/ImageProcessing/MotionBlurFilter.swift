//
//  MotionBlurFilter.swift
//  SwiftyImage
//
//  Created by tqtifnypmb on 13/12/2016.
//  Copyright © 2016 tqitfnypmb. All rights reserved.
//

import Foundation

/**
    Implement a Motion Blur
    based on http://graphics.snu.ac.kr/publications/conference_proceedings/2007-dykim-egwnp.pdf
 */
class MotionBlurFilter: BaseFilter {
    
    private let _angle: Double
    private let _length: Double
    
    /**
        init a [Motion blur](https://en.wikipedia.org/wiki/Motion_blur) filter
     
        - parameter angle: the angle of the motion blur
        - parameter length: the length of the motion blur effect
     */
    init(angle: Double, length: Double = 5.0) {
        _angle = angle
        _length = length
        super.init()
    }
}
