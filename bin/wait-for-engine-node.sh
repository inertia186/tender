#! /bin/bash

export MEESEEKER_ENGINE_NODE_URL="http://127.0.0.1:5000"

until $(curl --output /dev/null --silent --head $MEESEEKER_ENGINE_NODE_URL); do
  echo Waiting for engine node to start ...
  sleep 2
done
