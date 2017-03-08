//
//  MovieWriter.swift
//  Framenderer
//
//  Created by tqtifnypmb on 07/03/2017.
//  Copyright © 2017 tqtifnypmb. All rights reserved.
//

import Foundation
import AVFoundation

public class MovieWriter: FileStream {
    
    private var _started = false
    private let _frameWriter: FrameWriter
    public init(srcURL: URL, destURL: URL, fileType type: String = AVFileTypeMPEG4) throws {
        precondition(destURL.isFileURL)
        
        let asset = AVAsset(url: srcURL)
        guard let videoTrack = asset.tracks(withMediaType: AVMediaTypeVideo).first else {
            fatalError("Input file doesn't contain video track")
        }
        
        let width = GLsizei(videoTrack.naturalSize.width)
        let height = GLsizei(videoTrack.naturalSize.height)
        _frameWriter = try FrameWriter(destURL: destURL, type: type, width: width, height: height)
        _frameWriter.respectFrameTimeStamp = true
        
        try super.init(srcURL: srcURL)
    }
    
    public override func start() {
        guard !_started else { return }
        precondition(!filters.isEmpty)
        
        _started = true
        _frameWriter.startWriting()
        _additionalFilter = _frameWriter
        
        super.start()
    }
    
    public override func stop() {
        self.stop(completionHandler: nil)
    }
    
    public func stop(completionHandler handler: ((Void) -> Void)?) {
        guard _started else { return }
        
        _started = false
        _ctx.frameSerialQueue.async { [weak self] in
            self?._additionalFilter = nil
            self?._frameWriter.finishWriting {
                handler?()
            }
        }
        
        super.stop()
    }
    
    override func eof() {
        self.stop {
            print("EOF!!")
        }
    }
}
