# Use Ubuntu 14.04 as the base image
FROM ubuntu:14.04

# Define and label the build version and maintainer information
ARG BUILD_DATE
ARG VERSION
LABEL build_version="TK1 dev env version:- ${VERSION} build-date:- ${BUILD_DATE}"
LABEL maintainer="derrekito"

# Set the terminal environment variable
ENV TERM linux

# Set debconf frontend to non-interactive mode
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections
RUN echo "#!/bin/sh\nexit 0" > /usr/sbin/policy-rc.d

# Update package lists and install some essential packages
RUN apt-get update -y && apt-get install -y apt-utils wget ca-certificates

# Replace the default sources.list with a custom one
COPY trusty-sources.list /etc/apt/sources.list

# Add support for armhf architecture
RUN dpkg --add-architecture armhf

# Copy CUDA repo DEB package and install it
COPY cuda-repo-ubuntu1404_6.5-19_amd64.deb /tmp/
RUN dpkg -i /tmp/cuda-repo-ubuntu1404_6.5-19_amd64.deb

# Update the package list and upgrade installed packages
RUN apt-get update -y && apt-get upgrade -y

# Install build tools and libraries
RUN echo "installing buildtools"
RUN apt-get update -y && apt-get install -y cuda-toolkit-6-5 cuda-cross-armhf-6.5 build-essential gcc-arm-linux-gnueabihf git gfortran-4.8-arm-linux-gnueabihf libboost-all-dev

# Create a symbolic link
RUN ln -s /usr/bin/arm-linux-gnueabihf-gcc-ranlib-4.8 /usr/bin/arm-linux-gnueabihf-gcc-ranlib

# Set CUDA-related environment variables
ENV PATH="/usr/local/cuda-6.5/bin:${PATH}"
ENV export LD_LIBRARY_PATH="/usr/local/cuda-6.5/lib:$LD_LIBRARY_PATH"

# Clone and build OpenBLAS
RUN git clone https://github.com/xianyi/OpenBLAS.git
RUN export OMP_NUM_THREADS=4
RUN cd ./OpenBLAS && make \
    CC=arm-linux-gnueabihf-gcc-4.8 \
    FC=arm-linux-gnueabihf-gfortran-4.8 \
    HOSTCC=gcc-4.8 \
    TARGET=CORTEXA15 \
    RANLIB=ranlib \
    USE_OPENMP=1

# Install OpenBLAS
RUN cd ./OpenBLAS && make \
    CC=arm-linux-gnueabihf-gcc-4.8 \
    FC=arm-linux-gnueabihf-gfortran-4.8 \
    HOSTCC=gcc-4.8 \
    TARGET=CORTEXA15 \
    RANLIB=ranlib \
    USE_OPENMP=1 \
    PREFIX=/usr/local install

# Install DARKNET on TK1
# RUN sudo apt install cmake libopencv-dev
# WORKDIR /
# RUN git clone https://github.com/Derrekito/darknet.git
# WORKDIR darknet
# RUN make

# Create a directory for ARM sysroot and download specific Debian packages into it
RUN mkdir /opt/arm-sysroot
RUN wget --no-parent -nd -P /opt/arm-sysroot -r --no-clobber -A "*armhf.deb" http://ports.ubuntu.com/ubuntu-ports/pool/universe/b/boost1.54/
RUN wget --no-parent -nd -P /opt/arm-sysroot -r --no-clobber -A "*1.54*armhf.deb" http://ports.ubuntu.com/ubuntu-ports/pool/universe/b/boost-defaults/
RUN wget --no-parent -nd -P /opt/arm-sysroot -r --no-clobber -A "*armhf.deb" http://ports.ubuntu.com/ubuntu-ports/pool/main/b/boost1.54/

# Extract all downloaded Debian packages in the ARM sysroot directory
RUN cd /opt/arm-sysroot/ && \
    for file in *.deb; do dpkg-deb --extract "$file" /opt/arm-sysroot; done

# Change the working directory to root
WORKDIR /

#RUN wget -qO- "https://cmake.org/files/v3.8/cmake-3.8.0-Linux-x86_64.tar.gz" | tar --strip-components=1 -xz -C /usr/local
RUN wget -qO- "https://cmake.org/files/v3.14/cmake-3.14.0-Linux-x86_64.tar.gz" | tar --strip-components=1 -xz -C /usr/local


COPY armv7l-toolchain.cmake /
# Clone jsoncpp repository for a specific branch
RUN git clone -b 00.11.z https://github.com/Derrekito/jsoncpp.git

#Build and install jsoncpp for ARM64 architecture
WORKDIR jsoncpp
RUN mkdir build
WORKDIR build

RUN cmake -DCMAKE_INSTALL_PREFIX=/usr/arm-linux-gnueabihf \
    -DCMAKE_TOOLCHAIN_FILE=/armv7l-toolchain.cmake ..\
    && make \
    && make install

WORKDIR /
