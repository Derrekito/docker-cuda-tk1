FROM ubuntu:16.04

# set version label
ARG BUILD_DATE
ARG VERSION
LABEL build_version="TK1 dev env version:- ${VERSION} build-date:- ${BUILD_DATE}"
LABEL maintainer="derrekito"

ENV TERM linux
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections
RUN echo "#!/bin/sh\nexit 0" > /usr/sbin/policy-rc.d

RUN apt-get update -y && apt-get install -y apt-utils wget ca-certificates

#COPY trusty-sources.list /etc/apt/sources.list
COPY xenial-sources.list /etc/apt/sources.list


#RUN cat /etc/apt/sources.list

RUN apt-get update -y && apt-get install -y \
    gcc\
    g++\
    make\
    git\
    vim\
    emacs\
    libglu1-mesa-dev\
    libxi-dev\
    gcc-4.8-arm-linux-gnueabihf\
    gcc-4.8-multilib-arm-linux-gnueabihf\
    binutils-doc \
    gcc-4.8-locales\
    gcc-4.8-multilib-arm-linux-gnueabihf \
    gcc-4.8-doc\
    libgcc1-dbg-armhf-cross \
    libgomp1-dbg-armhf-cross \
    libatomic1-dbg-armhf-cross \
    libasan2-dbg-armhf-cross \
    libubsan0-dbg-armhf-cross \
    g++-4.8-arm-linux-gnueabihf\
    g++-4.8-multilib-arm-linux-gnueabihf


RUN dpkg --add-architecture armhf

#
#COPY cuda-repo-ubuntu1404_6.5-19_amd64.deb /tmp/
#RUN dpkg -i /tmp/cuda-repo-ubuntu1404_6.5-19_amd64.deb

#RUN apt-get update -y && apt-get install -y \
#    cuda-6.5 \
#    cuda-cross-armhf-6.5 \
#    cuda-toolkit-6-5 \
#    cuda-runtime-6-5

RUN apt-get update -y && apt-get upgrade -y

COPY cuda_6.5.14_linux_64.run /tmp/
RUN mkdir -p /usr/local/cuda-6.5
RUN mkdir -p /usr/local/cuda-samples
RUN /tmp/cuda_6.5.14_linux_64.run -toolkit -samples -silent --override -samplespath="/usr/local/cuda-samples"

ENV PATH="/usr/local/cuda-6.5/bin:${PATH}"
#ENV LD_LIBRARY_PATH="/usr/local/cuda-6.5/include:${LD_LIBRARY_PATH}"
ENV LD_LIBRARY_PATH="/usr/local/cuda-6.5/lib64:${LD_LIBRARY_PATH}"

#export LD_LIBRARY_PATH=/usr/local/cuda-6.5/lib:$LD_LIBRARY_PATH
