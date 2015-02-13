# crons

crontab_add "_common/s3dl/bin/baksql.js -d wordpress -b $s3Bucket/sql" "0 2 * * * /usr/local/bin/node /root/sire/_common/s3dl/bin/baksql.js -d wordpress -b $s3Bucket/sql > /var/log/$key_baksql.log 2>&1"
