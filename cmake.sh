sudo rm -r valhalla/build
mkdir $_
cd $_
mingw64-cmake  .. \
    -DCMAKE_CROSS_COMPILING=1 \
    -DCMAKE_BUILD_TYPE=Release \
    -DENABLE_TOOLS=ON \
    -DENABLE_DATA_TOOLS=OFF \
    -DENABLE_SERVICES=OFF \
    -DENABLE_PYTHON_BINDINGS=OFF \
    -DENABLE_CCACHE=OFF \
    -DENABLE_TESTS=OFF \
    -DENABLE_BENCHMARKS=OFF \
    -DBoost_PROGRAM_OPTIONS_LIBRARY=/usr/x86_64-w64-mingw32/sys-root/mingw/bin/libboost_program_options-mt-x64.dll
