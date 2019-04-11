#! /bin/bash

export PM2_HOME=/root/.pm2 

cd $SSC_ROOT
pm2 stop app.pm2.json
