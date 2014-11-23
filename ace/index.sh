
startpwd=`pwd`

. ../secrets

# modules
../_common/nginx.sh
../_common/php.sh
../_common/mysql.sh
../_common/nodejs.sh
../_common/forever.sh


# nginx conf
. ./nginx.sh

# repo
if [ ! -d "$installDir" ]; then
  mkdir -p "$installDir"
  git clone $gitRepo "$installDir"
fi
cd "$installDir"
git fetch
git checkout master
git pull origin master
git submodule init
git submodule update
npm install


# until i fix multiple github hooks issue...
gitsync_cron "$installDir" "master"


# let php write to out
chown -R www-data $installDir/web/public-out


# crons
chmod 0744 crons/*
crontab_add 'cleanup.sh' "0 4 * * * $installDir/crons/cleanup.sh '$installDir'"


# deploy hook service
#IP=`public_ip`
#echo '[{"repo":"'$installDir'","branch":"master"}]' > $installDir'/hooky.json'
#cd $startpwd/hooky
#npmi
#forever_run "./index.js -t $githubHookAuthToken -a $IP -c $installDir/hooky.json"
#cd $startpwd


#secret configs
printf "<?php\n" > $installDir/web/config.local.php
local_php_config_add "$installDir/web/config.local.php" twitterAppKey "$hopeTwitterAppKey"
local_php_config_add "$installDir/web/config.local.php" twitterAppSecret "$hopeTwitterAppSecret"
local_php_config_add "$installDir/web/config.local.php" sesKey "$sesKey"
local_php_config_add "$installDir/web/config.local.php" sesSecret "$sesSecret"
local_php_config_add "$installDir/web/config.local.php" awsRegion "$awsRegion"


