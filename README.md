### class-dump-swift

Right now this requires LLVM to parse mach-o's and get symbols from them. Hopefully we'll make it a bit more modular in the future so it doesn't depend on LLVM (since it is a big compile/install)

To get this working:

Download llvm source tree from http://llvm.org/releases/3.9.0/llvm-3.9.0.src.tar.xz (or newer will probably work fine).

    cd llvm-3.9.0.src/
    mkdir build
    cd build
    cmake ..
    make && sudo make install

Then you can successfully compile this project with just `make`. 

