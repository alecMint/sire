
startpwd=`pwd`

. ../secrets

# modules
../_common/s3.sh
../_common/nginx.sh
../_common/php.sh
../_common/mysql.sh
../_common/nodejs.sh
../_common/forever.sh


# nginx conf
. ./nginx.sh

# crons
. ./crons.sh

# repo
if [ ! -d "$installDir" ]; then
  mkdir -p "$installDir"
  git clone $gitRepo "$installDir"
fi
cd "$installDir"
git fetch
git checkout master
git pull origin master


# wordpress
echo 'create database if not exists wordpress' | mysql -uroot
# we need this file to be there immediately
mkdir -p $installDir/web/wp-content/uploads/x
s3cmd get s3://$hopeS3Bucket/wp-content/uploads/x/style.css $installDir/web/wp-content/uploads/x/style.css
# we may have a problem when s3 pulls down a directory that wasnt previously given permissions...
chown -R www-data $installDir/web/wp-content/uploads
chmod -R +w $installDir/web/wp-content/uploads


#secret configs
printf "<?php\n" > $installDir/web/config.override.php
local_php_config_add "$installDir/web/config.override.php" hopeTwitterAppKey "$hopeTwitterAppKey"
local_php_config_add "$installDir/web/config.override.php" hopeTwitterAppSecret "$hopeTwitterAppSecret"


# test cname
localhost_add_cname 'local.hopechapellongbeach.com'


# deploy hook service
IP=`public_ip`
echo "[{\"repo\":\"$installDir\",\"branch\":\"master\"}]" > "$installDir/hooky.json"
cd $startpwd/hooky
npmi
forever_run "./index.js -t $githubHookAuthToken -a $IP -c $installDir/hooky.json"
cd $startpwd

# s3 sync service
# NOTE: the angel script is pointed to wrong location, need to update to use $sireDir
cd $startpwd/../_common/s3dl
npmi
forever_run "./index.js -d $installDir/web/wp-content/uploads -w /wp-content/uploads -b sire-hope/wp-content/uploads"
cd $startpwd

# fetch wordpress data
node ../_common/s3dl/bin/loadsql.js -d wordpress -b sire-hope/sql

