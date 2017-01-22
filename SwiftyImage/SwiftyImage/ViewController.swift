//
//  ViewController.swift
//  SwiftyImage
//
//  Created by tqtifnypmb on 08/12/2016.
//  Copyright © 2016 tqitfnypmb. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var originImageView: UIImageView!
    @IBOutlet weak var processedImageView: UIImageView!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let origin = UIImage(named: "lena")
        let blend = UIImage(named: "zc")
        originImageView.image = origin
        
        do {
            let canva = ImageCanvas(image: origin!)
            
            let blendingFilter = LinearBlendFilter(source: blend!.cgImage!, a: 0.5)
            let gaussian = GaussianBlurFilter()
            canva.filters = [MedianBlurFilter(), blendingFilter, gaussian]
            try canva.process()
            
            let result = canva.processedImage()
            let processed = UIImage(cgImage: result)
            processedImageView.image = processed
        } catch {
            print(glGetError())
            print(error.localizedDescription)
        }
    }
}

