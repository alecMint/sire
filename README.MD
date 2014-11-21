Team effort with ma main man Ryan Day (github.com/soldair)

To Do
- Package hooky and remove dups
- Update _common/util.sh to use $sireDir as passed arg instead of hardcoded $dir
- Fix issue where only one hooky can be running at once due to port conflict


# clean up old server
node /root/sire/_common/s3dl/bin/baksql.js -d wordpress -b sire-hope/sql
node /root/sire/_common/s3dl/bin/shuv.js -d /var/www/hope/web/wp-content/uploads -b sire-hope/wp-content/uploads
crontab -r
killall node

# launch new one
# local:
./index.sh _deploy
# remote:
cd /root/sire
./index.sh hope
