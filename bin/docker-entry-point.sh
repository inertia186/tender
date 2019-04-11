#! /bin/bash

monit -t
monit
monit start all

$APP_ROOT/bin/wait-for-steem-engine-node.sh

export PM2_HOME=/root/.pm2
pm2 monit

echo Return to the Steem Engine monitor, type:
echo $'\t'pm2 monit
echo Or, to shut down this node, type:
echo $'\t'exit

/bin/bash
