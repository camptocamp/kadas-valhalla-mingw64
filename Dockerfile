FROM fedora:rawhide

LABEL maintainer=nils@gis-ops.com

RUN echo all > /etc/rpm/macros.image-language-conf && \
  dnf install -y \
    cmake \
    gcc-c++ \
    git \
    make \
    mingw64-curl \
    mingw64-boost \
    mingw64-protobuf \
    mingw64-sqlite \
    mingw64-libspatialite \
    mingw64-geos \
    mingw64-python3 \
    nano \
    protobuf-compiler \
    wget \
    which

# Install and patch boost-python, see commands MD
RUN wget https://dl.bintray.com/boostorg/release/1.73.0/source/boost_1_73_0.tar.bz2 && \
  tar -xjf boost_1_73_0.tar.bz2 && \
  rm boost_1_73_0.tar.bz2
  # Add the command(s) to patch the source with boost_1_73_0_patches
  # taken from

WORKDIR /workspace
CMD ["tail", "-f", "/dev/null"]
