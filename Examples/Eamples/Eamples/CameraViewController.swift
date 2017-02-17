//
//  CameraViewController.swift
//  SwiftyImage
//
//  Created by tqtifnypmb on 08/01/2017.
//  Copyright © 2017 tqitfnypmb. All rights reserved.
//

import UIKit
import SwiftyImage

class CameraViewController: UIViewController {
    var preview: CameraPreviewView!
    
    @IBOutlet weak var previewContainer: UIView!
    
    private let camera = StillImageCamera(cameraPosition: .back)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        preview = CameraPreviewView(frame: previewContainer.bounds)
        previewContainer.addSubview(preview)
        
        camera.previewView = self.preview
        // Do any additional setup after loading the view.
    }

    @IBAction func f(_ sender: Any) {
        let origin = UIImage(named: "lena")
        let blendingFilter = LinearBlendFilter(source: origin!.cgImage!, a: 0.5)
        let inverted = ColorInvertFilter()
        camera.filters = [inverted, HueAdjustFilter()]
        camera.startRunning()
    }
}
