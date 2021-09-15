## Build Valhalla with Fedora and MinGW64

Building the valhalla project this way lets you clone & edit Valhalla sources on the host machine, while the build happens inside the container:

1. Build the image to set up environment and dependencies:

   ```
   docker-compose build
   ```

2. Clone the right branch into the current working directory:

   ```
   git clone --recurse-submodules https://github.com/gis-ops/valhalla.git
   ```

3. Fire up container which has the current directory exposed in `/workspace`

   ```
   docker-compose up -d
   ```

4. Exec into the container:

   ```
   docker exec -it valhalla_mingw64 bash
   ```

5. Configure & run a build and collect all DLLs with the scripts below:

   ```
   ./cmake.sh && ./build.sh && ./copy_dll.sh
   ```

6. Zip up the build. **Note**, this copies all .dll's thought necessary, it hasn't been vetted.

   ```
   ls valhalla/build/*valhalla* valhalla/build/*.dll | zip -@ valhalla/build/valhalla_mingw64.zip
   ```
