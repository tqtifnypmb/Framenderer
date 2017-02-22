//
//  ViewController.swift
//  SwiftyImage
//
//  Created by tqtifnypmb on 08/12/2016.
//  Copyright © 2016 tqitfnypmb. All rights reserved.
//

import UIKit
import CoreImage
import SwiftyImage

class ViewController: UIViewController {

    @IBOutlet weak var originImageView: UIImageView!
    @IBOutlet weak var processedImageView: UIImageView!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let origin = UIImage(named: "lena")
        let blend = UIImage(named: "aero1")
        
        let context = CIContext()
        
        let filter = CIFilter(name: "CIHueAdjust")!
        
        filter.setValue(CIImage(cgImage: origin!.cgImage!), forKey: kCIInputImageKey)
        filter.setValue(2, forKey: kCIInputAngleKey)
       //filter.setValue(CIImage(cgImage: origin!.cgImage!), forKey: kCIInputBackgroundImageKey)
        let result = filter.outputImage!
        let cgImage = context.createCGImage(result, from: result.extent)
        originImageView.image = origin//UIImage(cgImage: cgImage!)
        
        do {
            let canva = ImageCanvas(image: origin!.cgImage!)

            canva.filters = [PassthroughFilter()]
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

