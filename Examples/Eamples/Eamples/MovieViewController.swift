//
//  MovieViewController.swift
//  Eamples
//
//  Created by tqtifnypmb on 08/03/2017.
//  Copyright © 2017 tqtifnypmb. All rights reserved.
//

import UIKit
import Framenderer

class MovieViewController: UIViewController {

    private var _movieWriter: MovieWriter!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let url = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        let src = url.appendingPathComponent("src.mp4")
        let dest = url.appendingPathComponent("dest.mp4")
        
        if FileManager.default.fileExists(atPath: dest.relativePath) {
            try! FileManager.default.removeItem(at: dest)
        }
        
        _movieWriter = try! MovieWriter(srcURL: src, destURL: dest)
        _movieWriter.filters = [PassthroughFilter()]
    }

    @IBAction func stopClicked(_ sender: Any) {
        _movieWriter.stop {
            print("finished!!")
        }
    }
    
    @IBAction func startClicked(_ sender: Any) {
        _movieWriter.start()
    }
}
