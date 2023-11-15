# Base image with Ubuntu 14.04
FROM ubuntu:14.04

# Set version label and maintainer label
ARG BUILD_DATE
ARG VERSION
LABEL build_version="TK1 dev env version:- ${VERSION} build-date:- ${BUILD_DATE}"
LABEL maintainer="derrekito"

# Set environment variable for terminal
ENV TERM linux
ENV LD_LIBRARY_PATH="/usr/local/cuda-6.5/lib64:/usr/local/cuda-6.5/targets/armv7-linux-gnueabihf/lib:${LD_LIBRARY_PATH}"

# Configure debconf for noninteractive mode
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections
RUN echo "#!/bin/sh\nexit 0" > /usr/sbin/policy-rc.d

# Update package list and install required packages
RUN apt-get update -y && apt-get install -y apt-utils wget ca-certificates

# Update apt sources list to trusty
COPY trusty-sources.list /etc/apt/sources.list

# Add armhf architecture
RUN dpkg --add-architecture armhf

# Copy and install CUDA 6.5 package
COPY cuda-repo-ubuntu1404_6.5-19_amd64.deb /tmp/
RUN dpkg -i /tmp/cuda-repo-ubuntu1404_6.5-19_amd64.deb

# Update package list and upgrade installed packages
RUN apt-get update -y && apt-get upgrade -y

# Install CUDA toolkit, cross-compiler, and other build tools
RUN echo "installing buildtools"
RUN apt-get update -y && apt-get install -y cuda-toolkit-6-5 cuda-cross-armhf-6.5 build-essential gcc-arm-linux-gnueabihf git gfortran-4.8-arm-linux-gnueabihf
RUN ln -s /usr/bin/arm-linux-gnueabihf-gcc-ranlib-4.8 /usr/bin/arm-linux-gnueabihf-gcc-ranlib

# Set environment variables for CUDA
ENV PATH="/usr/local/cuda-6.5/bin:${PATH}"
ENV export LD_LIBRARY_PATH="/usr/local/cuda-6.5/lib:$LD_LIBRARY_PATH"

# Install CuDNN
COPY cudnn-6.5-linux-x64-v2.tgz /tmp/
RUN tar -xvf /tmp/cudnn-6.5-linux-x64-v2.tgz -C /usr/local && rm /tmp/cudnn-6.5-linux-x64-v2.tgz
ENV LD_LIBRARY_PATH="/usr/local/cuda-6.5/lib64:${LD_LIBRARY_PATH}"

# Install Python, pip, and TensorFlow
RUN apt-get update -y && apt-get install -y python python-pip
RUN pip install --upgrade pip
RUN pip install https://storage.googleapis.com/tensorflow/linux/cpu/tensorflow-0.12.1-cp27-none-linux_x86_64.whl

# Clone and build OpenBLAS
RUN git clone https://github.com/xianyi/OpenBLAS.git
RUN export OMP_NUM_THREADS=4
RUN cd ./OpenBLAS && make CC=arm-linux-gnueabihf-gcc-4.8 FC=arm-linux-gnueabihf-gfortran-4.8 HOSTCC=gcc-4.8 TARGET=CORTEXA15 NUM_THREADS=4 #USE_OPENMP=1
