
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


# install repo
install_repo "$installDir" "$gitRepo"


# crons
chmod 0744 $installDir/crons/*
crontab_add "$installDir/crons/cleanup.sh" "0 4 * * * $installDir/crons/cleanup.sh '$installDir'"


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
if [ -f $installDir/web/config.local.php ]; then
	rm $installDir/web/config.local.php
fi
gen_add_line_to_file "$installDir/web/config.local.php" '<?php' '<?php'
gen_add_line_to_file "$installDir/web/config.local.php" twitterAppKey "\$twitterAppKey='$twitterAppKey';"
gen_add_line_to_file "$installDir/web/config.local.php" twitterAppSecret "\$twitterAppSecret='$twitterAppSecret';"
gen_add_line_to_file "$installDir/web/config.local.php" awsAccessKey "\$awsAccessKey='$awsAccessKey';"
gen_add_line_to_file "$installDir/web/config.local.php" awsAccessSecret "\$awsAccessSecret='$awsAccessSecret';"
gen_add_line_to_file "$installDir/web/config.local.php" awsRegion "\$awsRegion='$awsRegion';"
if [ "$googleAnalyticsId" != "" ]; then
	gen_add_line_to_file "$installDir/web/config.local.php" googleAnalyticsId "\$googleAnalyticsId='$googleAnalyticsId';"
fi

if [ -f $installDir/config.local.json ]; then
	rm $installDir/config.local.json
fi
gen_add_line_to_file "$installDir/config.local.json" '{'
gen_add_line_to_file "$installDir/config.local.json" awsAccessKey "\"awsAccessKey\": \"$awsAccessKey\""
gen_add_line_to_file "$installDir/config.local.json" awsAccessSecret ",\"awsAccessSecret\": \"$awsAccessSecret\""
gen_add_line_to_file "$installDir/config.local.json" awsRegion ",\"awsRegion\": \"$awsRegion\""
gen_add_line_to_file "$installDir/config.local.json" '}'


# rotate logs
logrotate_log=$installDir/out/logrotate.log
nginx_access_log=`grep access_log /etc/nginx/sites-enabled/ace | head -n1 | awk '{print $2}' | tr -d ';'`
nginx_error_log=`grep error_log /etc/nginx/sites-enabled/ace | head -n1 | awk '{print $2}' | tr -d ';'`
if [ "$nginx_access_log" != "" ] || [ "$nginx_error_log" != "" ]; then
	cron="0 2 * * * /bin/bash $sireDir/bin/logrotate.sh 10 '$nginx_access_log' '$nginx_error_log' '$logrotate_log' 2>&1 >> '$logrotate_log' #ace_rotateLogs"
	crontab_add '#ace_rotateLogs' "$cron"
fi



