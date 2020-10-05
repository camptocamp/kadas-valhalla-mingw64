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
    mingw64-python3-setuptools \
    nano \
    protobuf-compiler \
    wget \
    which

WORKDIR /workspace

CMD ["tail", "-f", "/dev/null"]
