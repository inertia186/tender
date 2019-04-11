#! /bin/bash

/usr/local/rvm/scripts/rvm && source /usr/local/rvm/scripts/rvm

export MEESEEKER_REDIS_URL="redis://127.0.0.1:6379/0"
export RAILS_ENV=production

cd $APP_ROOT
rvm use ruby-2.4.2

/usr/bin/nohup $(which bundle) exec $(which rails) server -b 0.0.0.0 -p 3000 > tender.log 2>&1 & echo $! > $APP_ROOT/tender.pid
