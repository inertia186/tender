#! /bin/bash

export PM2_HOME=/root/.pm2 
export NODE_URL="${STEEMD_NODE_URL}"

cd /steemsmartcontracts

tmpfile=$(mktemp)
cat config.json | jq ".streamNodes[0] |= \"${NODE_URL}\"" > ${tmpfile}
cat ${tmpfile} > config.json

cd $SSC_ROOT
pm2 start app.pm2.json --no-vizion
