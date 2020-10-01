## Build Valhalla on MinGW64

1. Run CMake to configure
```
mkdir build
cd build
mingw64-cmake  \
    -DCMAKE_CROSS_COMPILING=1 \
    -DCMAKE_BUILD_TYPE=Release \
    -DENABLE_TOOLS=ON \
    -DENABLE_DATA_TOOLS=OFF \
    -DENABLE_SERVICES=OFF \
    -DENABLE_PYTHON_BINDINGS=ON \
    -DENABLE_CCACHE=OFF \
    -DENABLE_TESTS=OFF \
    -DENABLE_BENCHMARKS=OFF \
    -DLOGGING_LEVEL=DEBUG \
    # Needs to be specified explicitly
    -DBoost_PROGRAM_OPTIONS_LIBRARY=/usr/x86_64-w64-mingw32/sys-root/mingw/lib/libboost_program_options-mt-x64.dll.a \
    ..

```

2. Run make to build
```
mingw64-make -C$PWD -j4 DESTDIR="$PWD/dist" VERBOSE=1
```

3. Copy DLLs to `./build`
```
cp \
  /usr/x86_64-w64-mingw32/sys-root/mingw/bin/iconv.dll \
  /usr/x86_64-w64-mingw32/sys-root/mingw/bin/libatomic-1.dll \
  /usr/x86_64-w64-mingw32/sys-root/mingw/bin/libboost_program_options-mt-x64.dll \
  /usr/x86_64-w64-mingw32/sys-root/mingw/bin/libbz2-1.dll \
  /usr/x86_64-w64-mingw32/sys-root/mingw/bin/libcharset-1.dll \
  /usr/x86_64-w64-mingw32/sys-root/mingw/bin/libcrypto-1_1-x64.dll \
  /usr/x86_64-w64-mingw32/sys-root/mingw/bin/libcurl-4.dll \
  /usr/x86_64-w64-mingw32/sys-root/mingw/bin/libexpat-1.dll \
  /usr/x86_64-w64-mingw32/sys-root/mingw/bin/libffi-6.dll \
  /usr/x86_64-w64-mingw32/sys-root/mingw/bin/libfreexl-1.dll \
  /usr/x86_64-w64-mingw32/sys-root/mingw/bin/libgcc_s_seh-1.dll \
  /usr/x86_64-w64-mingw32/sys-root/mingw/bin/libgeos* \
  /usr/x86_64-w64-mingw32/sys-root/mingw/bin/libidn2-0.dll \
  /usr/x86_64-w64-mingw32/sys-root/mingw/bin/libpro* \
  /usr/x86_64-w64-mingw32/sys-root/mingw/bin/libs* \
  /usr/x86_64-w64-mingw32/sys-root/mingw/bin/libwinpthread-1.dll \
  /usr/x86_64-w64-mingw32/sys-root/mingw/bin/libxml2-2.dll \
  /usr/x86_64-w64-mingw32/sys-root/mingw/bin/zlib1.dll \
  valhalla_previous/build

cp valhalla_previous/build/src/libvalhalla.dll valhalla_previous/build
```

4. Zip the relevant modules
```
ls valhalla_previous/build/*valhalla* valhalla_previous/build/*.dll | zip -@ valhalla_mingw64.zip
```

## Fedora package build patches

from https://blog.aloni.org/posts/how-to-easily-patch-fedora-packages/

1. Install tools
```
dnf install -y fedpkg make
```

2. Query for remote Git repo
```
rpm -qif /usr/x86_64-w64-mingw32/sys-root/mingw/lib/libprotobuf.dll.a | grep 'Source RPM'
```

3. Clone the repo to workspace
```
fedpkg co -a mingw-protobuf
cd mingw-protobuf
```

4. Identify the correct branch to patch

5. Build dependencies for current package
```
dnf builddep mingw-protobuf
```

6. Prepare package by getting sources (this case original protobuf source from Github)
```
fedpkg prep
```

7. Init own git repo for patched version
```
# Move to uninitialized folder
mv protobuf-3.13.0 ../protobuf-3.13.0
cd ../protobuf-3.13.0
git init && git add -f . && git commit -m "sandro's base version"
```

8. Patch whatever you need to patch there and produce diff
```
git add .
git commit -m "patched"
git format-patch HEAD~1 -o ../protobuf-3.13.0
```

9. Change the `Release` entry in the `.spec` file and build the package.
```
nano mingw-protobuf.spec
fedpkg local
```

10. Check for new builds and install
```
ls -l1 noarch/
dnf install -y noarch/mingw64-protobuf-3.13.0-2.fc34.noarch.rpm
dnf list installed | grep @@commandline
```

## Helpers

### Build Boost with MinGW64 on Fedora

1. Get the sources
```
wget https://dl.bintray.com/boostorg/release/1.73.0/source/boost_1_73_0.tar.bz2
tar -xjf boost_1_73_0.tar.bz2
```

2. Setup `~/user-config.jam`
```
cat >> ~/user-config.jam <<EOL
using gcc : mingw64 : x86_64-w64-mingw32-g++ ;

using python
     : 3.9
     : /usr/x86_64-w64-mingw32/sys-root/mingw/bin/python3.9
     : /usr/x86_64-w64-mingw32/sys-root/mingw/include/python3.9
     : /usr/x86_64-w64-mingw32/sys-root/mingw/lib/python3.9/config-3.9 ;
EOL
```

3. Bootstrap boost
```
./bootstrap.sh --with-icu=/usr/x86_64-w64-mingw32/sys-root/mingw/ --with-toolset=gcc
```

4. Patch all files in `./boost_1_73_0_patches`

Mostly like this:
```
patch -p1 -i patches/boost-1.63.0-python-test-PyImport_AppendInittab.patch
```

5. Build boost-python
```
./b2 address-model=64 link=shared runtime-link=shared threading=multi threadapi=win32 toolset=gcc variant=release python=3.9 --with-python
```

### Find dependency DLLs for exe's (pe-util)

Just leaving this here since I went through the "trouble" of trying it out. Didn't really work though, lots of unmet dependencies left.

```
dnf install -y \
    boost-devel \
    glibc-devel && \
git clone --recurse-submodules https://github.com/gsauthof/pe-util.git && \
mkdir build && \
cmake .. -DCMAKE_BUILD_TYPE=Release && \
make
ln -s $PWD/peldd /usr/local/bin
```
