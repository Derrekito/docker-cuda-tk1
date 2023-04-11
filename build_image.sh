#!/bin/bash


TAG="cudatools:6.5"

if [[ ! -f cuda-repo-ubuntu1404_6.5-19_amd64.deb ]]
then
    wget http://developer.download.nvidia.com/compute/cuda/repos/ubuntu1404/x86_64/cuda-repo-ubuntu1404_6.5-19_amd64.deb
fi

if [[ ! -f cudnn-6.5-linux-ARMv7-v2.tgz ]]
then
    echo "Download cudnn for 6.5 from https://developer.nvidia.com/rdp/cudnn-archive"
    exit 1
fi
docker build --tag "$TAG" .
