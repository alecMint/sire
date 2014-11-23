
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

# until i fix multiple github hooks issue...
gitsync_cron "$installDir" "master"


#secret configs
#printf "<?php\n" > $installDir/web/config.local.php
gen_add_line_to_file "$installDir/web/config.local.php" '<?php' '<?php'
gen_add_line_to_file "$installDir/web/config.local.php" twitterAppKey "\$twitterAppKey='$hopeTwitterAppKey'"
gen_add_line_to_file "$installDir/web/config.local.php" twitterAppSecret "\$twitterAppSecret='$hopeTwitterAppSecret'"
gen_add_line_to_file "$installDir/web/config.local.php" sesKey "\$sesKey='$sesKey'"
gen_add_line_to_file "$installDir/web/config.local.php" sesSecret "\$sesSecret='$sesSecret'"
gen_add_line_to_file "$installDir/web/config.local.php" awsRegion "\$awsRegion='$awsRegion'"

gen_add_line_to_file "$installDir/config.local.json" '{'
gen_add_line_to_file "$installDir/config.local.json" sesKey "\"sesKey\": \"$sesKey\""
gen_add_line_to_file "$installDir/config.local.json" sesSecret ",\"sesSecret\": \"$sesSecret\""
gen_add_line_to_file "$installDir/config.local.json" awsRegion ",\"awsRegion\": \"$awsRegion\""
gen_add_line_to_file "$installDir/config.local.json" '}'

