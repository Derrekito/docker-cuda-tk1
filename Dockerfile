# Use Ubuntu 14.04 as the base image
FROM ubuntu:14.04

# Define and label the build version and maintainer information
ARG BUILD_DATE
ARG VERSION
LABEL build_version="TK1 dev env version:- ${VERSION} build-date:- ${BUILD_DATE}"
LABEL maintainer="derrekito"

# Set the terminal environment variable and non-interactive frontend
ENV TERM linux
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections \
    && echo "#!/bin/sh\nexit 0" > /usr/sbin/policy-rc.d

# Update package lists, install essential packages, and clean up
RUN apt-get update -y && apt-get install -y apt-utils wget ca-certificates \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Replace the default sources.list with a custom one and add armhf architecture
COPY trusty-sources.list /etc/apt/sources.list
RUN dpkg --add-architecture armhf

# Copy CUDA repo DEB package, install it, and clean up
COPY cuda-repo-ubuntu1404_6.5-19_amd64.deb /tmp/
RUN dpkg -i /tmp/cuda-repo-ubuntu1404_6.5-19_amd64.deb && rm /tmp/cuda-repo-ubuntu1404_6.5-19_amd64.deb

# Update and upgrade packages
RUN apt-get update -y && apt-get upgrade -y && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install build tools, libraries, and create a symbolic link
RUN apt-get update -y && apt-get install -y cuda-toolkit-6-5 cuda-cross-armhf-6.5 build-essential gcc-arm-linux-gnueabihf git \
    gfortran-4.8-arm-linux-gnueabihf libboost-all-dev \
    && ln -s /usr/bin/arm-linux-gnueabihf-gcc-ranlib-4.8 /usr/bin/arm-linux-gnueabihf-gcc-ranlib \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Set CUDA-related environment variables
ENV PATH="/usr/local/cuda-6.5/bin:${PATH}"
ENV LD_LIBRARY_PATH="/usr/local/cuda-6.5/lib:$LD_LIBRARY_PATH"

# Clone, build, and install OpenBLAS
RUN git clone https://github.com/xianyi/OpenBLAS.git \
    && cd OpenBLAS && make \
    CC=arm-linux-gnueabihf-gcc-4.8 \
    FC=arm-linux-gnueabihf-gfortran-4.8 \
    HOSTCC=gcc-4.8 \
    TARGET=CORTEXA15 \
    RANLIB=ranlib \
    NUM_THREADS=4 \
    USE_OPENMP=0 \
    && make PREFIX=/usr/local install

# Create a directory for ARM sysroot and download specific Debian packages for Boost C++ library into it
RUN mkdir /opt/arm-sysroot \
    && wget --no-parent -nd -P /opt/arm-sysroot -r --no-clobber -A "*armhf.deb" http://ports.ubuntu.com/ubuntu-ports/pool/universe/b/boost1.54/ \
    && wget --no-parent -nd -P /opt/arm-sysroot -r --no-clobber -A "*1.54*armhf.deb" http://ports.ubuntu.com/ubuntu-ports/pool/universe/b/boost-defaults/ \
    && wget --no-parent -nd -P /opt/arm-sysroot -r --no-clobber -A "*armhf.deb" http://ports.ubuntu.com/ubuntu-ports/pool/main/b/boost1.54/ \
    && cd /opt/arm-sysroot/ \
    && for file in *.deb; do dpkg-deb --extract "$file" /opt/arm-sysroot; done \
    && rm -f /opt/arm-sysroot/*.deb

# Download and install CMake
RUN wget -qO- "https://cmake.org/files/v3.14/cmake-3.14.0-Linux-x86_64.tar.gz" | tar --strip-components=1 -xz -C /usr/local


# Copy the toolchain file into the Docker image
COPY armv7l-toolchain.cmake /

# Clone jsoncpp repository for a specific branch
RUN git clone -b 00.11.z https://github.com/Derrekito/jsoncpp.git \
    && cd jsoncpp \
    && mkdir build \
    && cd build \
    && cmake -DCMAKE_INSTALL_PREFIX=/usr/arm-linux-gnueabihf \
    -DCMAKE_TOOLCHAIN_FILE=/armv7l-toolchain.cmake .. \
    && make \
    && make install

# Set environment variable for library path
ENV LD_LIBRARY_PATH=/usr/arm-linux-gnueabihf/lib:$LD_LIBRARY_PATH

# Set the working directory back to root
WORKDIR /

