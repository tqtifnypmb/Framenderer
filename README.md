
### Overview
The Framenderer is a framework that lets you process image from various sources, image file, video file, live camera, etc. 

It takes advantage the power of OpenGL v3.0 and the power of GPU, to make image processing more effecient.

### Architecture
Framenderer's core concepts are Frame Stream and Filter. Frame Stream is a serial of frame(Image with timestamp) fly from source through a set of Filter.Filter is a [pure-function](https://en.wikipedia.org/wiki/Pure_function) object which transform the inputed frame to output.

##### Frame Stream
Frame Stream is based on [Continuation](https://wiki.haskell.org/Continuation) notion, maybe not in a strict way though. This bring two advantages:
- When every single frame flies from its source, the set of filters installed at that time will be captured and applied in a stand-alone environment. So there's no need to synchronize between user and Framenderer.
- By capturing all the filters that will be applied to the flying frame, Framenederer can make sure filters are applied in order, without bookkeeping and synchronization overhead. This not only leads to neat design of framework structure but also makes filter much more easier to write.

          Frames ---> Continuation --> Continuatoin --> ...
                         |
                         |
              ------------------------------------------------
              |Timestamp                                      |
              |Frame ----      --- Frame --     ---- Frame... |
              |          \    /            \   /              |
              |          Filter            Filter        ...  |
              ------------------------------------------------

##### Filter
Filters are a processing unit. They're responsible for almost all the processing tasks in Framenderer. 
In order to keep Framenderer effecient, Framenderer takes advantage of system's cache mechanism when possible.

In Framenderer, textures and frame buffer objects are created using relative cache mechanism. By doing so, the overhead of render data transfering between CPU and GPU is greatly decline, which make filters run much more faster.

[Current supported filters](https://developer.apple.com/library/content/documentation/GraphicsImaging/Reference/CoreImageFilterReference/index.html#//apple_ref/doc/uid/TP40004346)

#### Usage
##### Image Process
    // create a canva filled with `original`
    let canva = ImageCanvas(image: original) 
    
    // setup filters chain: Gaussian blur --> Median blur
    canva.filters = [GaussianBlurFilter(), MedianBlurFilter()]

    // process
    canva.processAsync { processedImage, error in
        // handle processing result
    }

##### Capture Image
    // create a camera for image capturing
    let camera = StillImageCamera()

    // setup filters chain
    camera.fileters = [GammaAdjustFilter(), ColorInvertFilter()]

    // start runing the camera
    camera.start()

    camera.takePhoto { photo, error in
        //handle result
    }

##### Capture Video
    // create a camera for video capturing
    let camera = VideoCamera(...)

    // setup filters chain
    camera.filters = [...]

    // run the camera
    camera.start()

    camera.startRecording()
    
    camera.finishRecording {
        // handle result
    }

##### Movie rewrite

    let writer = MovieWriter(...)
    
    writer.filters = [...]

    writer.start()

