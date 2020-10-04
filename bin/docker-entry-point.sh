#! /bin/bash

service mongodb start

cd $SSC_ROOT

if [ ! -d $SSC_ROOT/mongoarchive ]; then
  mkdir mongoarchive
  curl -SL "https://api.hive-engine.com/ssc.archive" -o mongoarchive/ssc.archive
  mongorestore --gzip --archive=mongoarchive/ssc.archive
  rm mongoarchive/ssc.archive
fi

block_num=$(echo "db.getCollection('chain').find({}).sort({_id:-1}).limit(1)[0][\"refSteemBlockNumber\"] + 1" | mongo --quiet ssc)
tmpfile=$(mktemp)
cat config.json | jq ".startSteemBlock |= ${block_num}" > ${tmpfile}
cat ${tmpfile} > config.json

monit -t
monit
monit start all

$APP_ROOT/bin/wait-for-engine-node.sh

export PM2_HOME=/root/.pm2
pm2 monit

echo Return to the Steem Engine monitor, type:
echo $'\t'pm2 monit
echo Or, to shut down this node, type:
echo $'\t'exit

/bin/bash
