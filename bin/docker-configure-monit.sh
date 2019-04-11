#! /bin/bash

cat << DONE >> /etc/logrotate.d/tender
/tender/tmp/log/*.log {
    weekly
    missingok
    rotate 52
    compress
    delaycompress
    notifempty
    copytruncate
}
DONE

chmod 600 /etc/logrotate.d/tender

cat << DONE >> /etc/monit/monitrc
set httpd port 2812 and
    use address localhost  # only accept connection from localhost
    allow localhost        # allow localhost to connect to the server and
    
check process steem-engine-contracts matching "node /steemsmartcontracts/app.js"
  start program = "$APP_ROOT/bin/start-steem-smart-contracts.sh"
    with timeout 90 seconds
  stop program = "$APP_ROOT/bin/stop-steem-smart-contracts.sh"
    with timeout 90 seconds
  group steem-smart-contracts

check process redis-server matching "/usr/local/bin/redis-server \*:6379"
  start program = "/bin/bash -c '/usr/local/bin/redis-server --daemonize yes'"
    with timeout 90 seconds
  stop program = "/bin/bash -c '/usr/local/bin/redis-cli shutdown'"
    with timeout 90 seconds
  group redis-server
  
check process meeseeker pidfile /meeseeker/meeseeker.pid
  depends on steem-engine-contracts
  depends on redis-server
  start program = "/bin/bash -c '$APP_ROOT/bin/start-meeseeker.sh'"
    with timeout 90 seconds
  stop program = "/bin/bash -c '$APP_ROOT/bin/stop-meeseeker.sh'"
    with timeout 90 seconds
  group meeseeker
  if status != 0 for 5 cycles then restart steem-engine-contracts
  
check process tender pidfile $APP_ROOT/tender.pid
  depends on steem-engine-contracts
  depends on redis-server
  depends on meeseeker
  start program = "/bin/bash -c '$APP_ROOT/bin/start-tender.sh'"
    with timeout 90 seconds
  stop program = "/bin/bash -c '$APP_ROOT/bin/stop-tender.sh'"
    with timeout 90 seconds
  group tender

check program "tender-trx-ingest" with path "$APP_ROOT/bin/tender-trx-ingest.sh"
  if status != 0 for 5 cycles then alert
  every 1 cycles
  group tender
DONE

chmod 700 /etc/monit/monitrc
