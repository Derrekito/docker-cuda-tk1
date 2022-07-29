#!/bin/bash

LOCAL_DIR="/tmp/shared"
CONTAINER_DIR="/shared"

IMAGE_TAG="cudatools:6.5"
CONTAINER_NAME="docker-cuda"

docker run -it -v $LOCAL_DIR:$CONTAINER_DIR --name $CONTAINER_NAME $IMAGE_TAG