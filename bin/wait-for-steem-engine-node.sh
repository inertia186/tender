#! /bin/bash

export MEESEEKER_STEEM_ENGINE_NODE_URL="http://127.0.0.1:5000"

until $(curl --output /dev/null --silent --head $MEESEEKER_STEEM_ENGINE_NODE_URL); do
  echo Waiting for steem-engine node to start ...
  sleep 2
done
