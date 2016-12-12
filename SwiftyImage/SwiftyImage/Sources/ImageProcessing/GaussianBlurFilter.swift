//
//  GaussianBlurFilter.swift
//  SwiftyImage
//
//  Created by tqtifnypmb on 12/12/2016.
//  Copyright © 2016 tqitfnypmb. All rights reserved.
//

import Foundation
import OpenGLES.ES3.gl
import OpenGLES.ES3.glext

public class GaussianBlurFilter: Filter {
    enum Strategy {
        case box
    }
    
    let _sigma: Int
    let _strategy: Strategy
    var boxPass: Int = 3
    init(radius sigma: Int, strategy: Strategy = .box) {
        _sigma = sigma
        _strategy = strategy
    }
    
    func apply(context: Context) throws {
        switch _strategy {
        case .box:
            let blur = BoxGaussianBlurFilter(sigma: _sigma, pass: max(boxPass, 3))
            try blur.apply(context: context)
        }
    }
}

/// based on: http://blog.ivank.net/fastest-gaussian-blur.html
private class BoxGaussianBlurFilter: Filter {
    
    private var _boxBlurSize: [Int] = []
    init(sigma: Int, pass: Int) {
        _boxBlurSize = calculateBoxBlurSize(sigma: sigma, pass: pass)
    }
    
    private func calculateBoxBlurSize(sigma: Int, pass: Int) -> [Int] {
        let wIdeal = sqrt(Double(12 * sigma * sigma / pass + 1))
        var wl = Int(floor(wIdeal))
        if wl % 2 == 0 {
            wl -= 1
        }
        
        let wu = wl + 2
      
        let mIdeal = (12 * sigma * sigma - pass * wl * wl - 4 * pass * wl - 3 * pass) / (-4 * wl - 4)
        let m = round(Double(mIdeal))
        
        var ret: [Int] = []
        for i in 0 ..< pass {
            let size = Double(i) < m ? wl : wu
            ret.append(size)
        }
        return ret
    }
    
    func apply(context: Context) throws {
        for size in _boxBlurSize {
            let box = BoxBlurFilter(radius: size)
            try box.apply(context: context)
        }
    }
}
