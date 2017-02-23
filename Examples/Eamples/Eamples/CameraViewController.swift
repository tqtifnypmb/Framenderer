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
    
    private var camera: VideoCamera!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        var url = try! FileManager.default.url(for: .applicationDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        url.appendPathComponent("tmp.mp4")
        
        let width = self.view.bounds.width
        let height = self.view.bounds.height
        camera = try! VideoCamera(outputURL: url, width: Int32(width), height: Int32(height))
        
        preview = CameraPreviewView(frame: previewContainer.bounds)
        previewContainer.addSubview(preview)
        
        camera.previewView = self.preview
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
//        let origin = UIImage(named: "lena")
//        let blendingFilter = LinearBlendFilter(source: origin!.cgImage!, a: 0.5)
//        let inverted = ColorInvertFilter()
//        let hueAdjust = HueAdjustFilter()
        camera.filters = [PassthroughFilter()]
        camera.startRunning()
    }

    @IBAction func f(_ sender: Any) {
        camera.startRecording()
//        camera.takePhoto { error, image in
//            if let cgImage = image {
//                DispatchQueue.main.async {
//                    let imageView = UIImageView(frame: self.view.bounds)
//                    imageView.image = UIImage(cgImage: cgImage)
//                    self.view.addSubview(imageView)
//                }
//            } else if let error = error {
//                fatalError(error.localizedDescription)
//            }
//        }
    }
}
