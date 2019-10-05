#!/bin/bash

IMAGE_NAME=ros1_python3:latest

SCRIPT_DIR=$(cd $(dirname $0); pwd)

docker run -it --rm \
  --runtime=nvidia \
  --volume="$SCRIPT_DIR/:/root/ros1_python3/" \
  --net="host" \
  $IMAGE_NAME \
  bash -c "source /ros_entrypoint.sh $@"
