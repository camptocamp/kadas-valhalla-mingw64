## Build Valhalla with Fedora and MinGW64

Building the valhalla project this way lets you clone & edit Valhalla sources on the host machine, while the build happens inside the container:

1. Build the image to
  - set up environment and dependencies
  - clone the right valhalla branch

```
docker-compose build
```

2. Clone the right branch into the cwd:

```
git clone --recurse-submodules https://github.com/gis-ops/valhalla.git
cd valhalla
git checkout shortestish_mignw_merge
```

3. Fire up container which has the current directory exposed in `/workspace`

```
docker-compose up -d
```

4. Exec into the container, configure & run a build and collect all DLLs:

```
docker exec -it valhalla_mingw64 bash
chmod +x build.sh cmake.sh copy_dll.sh
cmake.sh && build.sh && copy_dll.sh
```

5. Zip up the build. **Note**, I really copy ALL DLLs which are somehow needed (also some legacy ones, e.g. Python is not needed anymore), will need some testing which ones are relevant/superfluous. Or configure another build to only work with static libraries.. Sounds more painful though..

```
ls valhalla/build/*valhalla* valhalla/build/*.dll | zip -@ valhalla_mingw64.zip
```
