FROM ubuntu:14.04

# set version label
ARG BUILD_DATE
ARG VERSION
LABEL build_version="TK1 dev env version:- ${VERSION} build-date:- ${BUILD_DATE}"
LABEL maintainer="derrekito"

ENV TERM linux
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections
RUN echo "#!/bin/sh\nexit 0" > /usr/sbin/policy-rc.d

RUN apt-get update -y && apt-get install -y apt-utils wget ca-certificates

COPY trusty-sources.list /etc/apt/sources.list
#COPY xenial-sources.list /etc/apt/sources.list
RUN dpkg --add-architecture armhf

COPY cuda-repo-ubuntu1404_6.5-19_amd64.deb /tmp/
RUN dpkg -i /tmp/cuda-repo-ubuntu1404_6.5-19_amd64.deb
RUN apt-get update -y && apt-get upgrade -y

RUN echo "installing standard buildtools"
RUN apt-get update -y && apt-get install -y     \
    build-essential gcc-arm-linux-gnueabihf git

#RUN echo "installing editers"
#RUN apt-get update -y && apt-get install -y     \
#    vim nano emacs

RUN echo "installing cuda toolkit"
RUN apt-get update -y && apt-get install -y cuda-toolkit-6-5

RUN echo "installing cuda cross tools"
RUN apt-get update -y && apt-get install -y cuda-cross-armhf-6.5

RUN apt-get install libblas-dev
#RUN apt-get update -y && apt-get upgrade -y

ENV PATH="/usr/local/cuda-6.5/bin:${PATH}"
ENV LD_LIBRARY_PATH="/usr/local/cuda-6.5/lib:$LD_LIBRARY_PATH"
