//
//  Filter.swift
//  SwiftyImage
//
//  Created by tqtifnypmb on 08/12/2016.
//  Copyright © 2016 tqitfnypmb. All rights reserved.
//

protocol Filter {
    func apply(context: Context) throws
}
