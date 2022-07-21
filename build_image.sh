#!/bin/bash

TAG="cudatools:6.5"

if [[ ! -f cuda-repo-ubuntu1404_6.5-19_amd64.deb ]]                                                         
then
    wget http://developer.download.nvidia.com/compute/cuda/repos/ubuntu1404/x86_64/cuda-repo-ubuntu1404_6.5-19_amd64.deb
fi

docker build --tag "$TAG" .
