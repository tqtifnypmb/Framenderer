//
//  ViewController.swift
//  SwiftyImage
//
//  Created by tqtifnypmb on 08/12/2016.
//  Copyright © 2016 tqitfnypmb. All rights reserved.
//

import UIKit
import CoreImage

class ViewController: UIViewController {

    @IBOutlet weak var originImageView: UIImageView!
    @IBOutlet weak var processedImageView: UIImageView!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let origin = UIImage(named: "lena")
        let blend = UIImage(named: "aero1")
        
        let context = CIContext()
        
        let filter = CIFilter(name: "CISaturationBlendMode")!
        
        filter.setValue(CIImage(cgImage: blend!.cgImage!), forKey: kCIInputImageKey)
        filter.setValue(CIImage(cgImage: origin!.cgImage!), forKey: kCIInputBackgroundImageKey)
        let result = filter.outputImage!
        let cgImage = context.createCGImage(result, from: result.extent)
        originImageView.image = UIImage(cgImage: cgImage!)
        
        do {
            let canva = ImageCanvas(image: origin!)

            let test = SaturationBlendFilter(otherImage: blend!.cgImage!)
            let motion = MotionBlurFilter(angle: 0, distance: 25)
            canva.filters = [test]
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

