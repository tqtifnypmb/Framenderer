//
//  CameraViewController.swift
//  SwiftyImage
//
//  Created by tqtifnypmb on 08/01/2017.
//  Copyright © 2017 tqitfnypmb. All rights reserved.
//

import UIKit

class CameraViewController: UIViewController {
    @IBOutlet weak var preview: CameraPreviewView!
    
    private let camera = StillImageCamera(cameraPosition: .back)

    override func viewDidLoad() {
        super.viewDidLoad()

        camera.previewView = self.preview
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func f(_ sender: Any) {
        let origin = UIImage(named: "zc")
        let median = MedianBlurFilter()
        //camera.filters = [median]
        camera.startRunning()
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
