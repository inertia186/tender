#! /bin/bash

/usr/local/rvm/scripts/rvm && source /usr/local/rvm/scripts/rvm

export MEESEEKER_NODE_URL="${STEEMD_NODE_URL}"
export MEESEEKER_STEEM_ENGINE_NODE_URL="http://127.0.0.1:5000"
export MEESEEKER_REDIS_URL="redis://127.0.0.1:6379/0"
export MEESEEKER_EXPIRE_KEYS="-1"

AT_BLOCK_NUM=`redis-cli get steem_engine:meeseeker:last_block_num`

if [ -z "$AT_BLOCK_NUM" ]; then
  AT_BLOCK_NUM="1"
fi

cd /meeseeker
rvm use ruby-2.4.2

$APP_ROOT/bin/wait-for-steem-engine-node.sh

/usr/bin/nohup $(which bundle) exec $(which rake) sync[steem_engine,$AT_BLOCK_NUM] > meeseeker.log 2>&1 & echo $! > /meeseeker/meeseeker.pid
