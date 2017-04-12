//
//  ViewController.swift
//  Framenderer
//
//  Created by tqtifnypmb on 08/12/2016.
//  Copyright © 2016 tqitfnypmb. All rights reserved.
//

import UIKit
import CoreImage
import Framenderer

class ViewController: UIViewController {

    @IBOutlet weak var originImageView: UIImageView!
    @IBOutlet weak var processedImageView: UIImageView!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let origin = UIImage(named: "lena")
//        let blend = UIImage(named: "lena")
//        
//        let context = CIContext()
//        
//        let filter = CIFilter(name: "CIAdditionCompositing")!
        
        //filter.setValue(CIImage(cgImage: origin!.cgImage!), forKey: kCIInputImageKey)
//        filter.setValue(2, forKey: kCIInputAngleKey)
        //filter.setValue(CIImage(cgImage: blend!.cgImage!), forKey: kCIInputBackgroundImageKey)
        //let result = filter.outputImage!
        //let cgImage = context.createCGImage(result, from: result.extent)
        //originImageView.image = UIImage(cgImage: cgImage!)
        
        originImageView.image = origin
        
        let canva = ImageCanvas(image: origin!.cgImage!)
        let canny = CannyFilter(lowerThresh: 0.0, upperThresh: 1.0)
        
        canva.filters = [PassthroughFilter(), HistogramFilter()]
       // canva.filters = canny.expand()
       // canva.filters.append(PassthroughFilter())
        canva.processAsync {[weak self] result, error in
            if let error = error {
                print(glGetError())
                print(error.localizedDescription)
            } else {
                let processed = UIImage(cgImage: result!)
                
                DispatchQueue.main.async {
                    self?.processedImageView.image = processed
                }
            }
        }
    }
}

