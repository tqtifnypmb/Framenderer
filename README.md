### Framenderer

#### Overview
The Framenderer is a framework that lets you process image from various sources, image file, video file, live camera... etc. 

It takes advantage the power of OpenGL v3.0 and the power of GPU, to make image processing more effeciently.

#### Architecture
Framenderer's core concepts are Frame Stream and Filter. Frame Stream is a serial of frame(Image with timestamp) fly from source through a set of Filter.Filter is a [pure-function](https://en.wikipedia.org/wiki/Pure_function) object which transform the inputed frame to output.

###### Frame Stream
Frame Stream is based on [Continuation](https://wiki.haskell.org/Continuation), maybe not in a strict way though. This bring two advantages:
- When every single frame fly from its source, the set of filters installed at that time will be captured and applied in a stand-alone environment. So there's no need to synchronize between user and Framenderer.
- By capturing all the filters that will be applied to the flying frame, Framenederer can make sure filters are applied in order, while no bookkeeping and synchronization is needed. This not only lead to neat framework structure also make filter is much more easy to write.

          Source ---> Continuation --> Continuatoin --> ...
                         |
                         |
             -----------------------------------
             |Timestamp                        |
             |Frame --> Filter --> Filter ...  |
             ----------------------------------

###### Filter
Filters are process unit. They're responsible for almost all the processing tasks in Framenderer. 
In order to keep Framenderer effecient, Framenderer takes advantage of system's cache mechanism when possible. In Framenderer, textures and frame buffer objects are created using relative cache mechanism. By doing so, the overhead of render data transfering between CPU and GPU is greatly decline, which make filters run much more faster.
