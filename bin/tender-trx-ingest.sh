#! /bin/bash

source /usr/local/rvm/scripts/rvm

export MEESEEKER_REDIS_URL="redis://127.0.0.1:6379/0"
export RAILS_ENV=production

cd $APP_ROOT
rvm use ruby-2.4.2
/usr/bin/nohup $(which bundle) exec $(which rake) tender:trx_ingest > tender-trx-ingest.log 2>&1
