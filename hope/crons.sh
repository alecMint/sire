# crons

crontab_add "_common/s3dl/bin/baksql.js -d wordpress -b sire-hope/sql" "0 3 * * * /usr/local/bin/node /root/sire/_common/s3dl/bin/baksql.js -d wordpress -b sire-hope/sql >> /var/log/hope_baksql.log 2>&1"
