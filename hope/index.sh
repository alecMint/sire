
startpwd=`pwd`

. ../secrets

# modules
../_common/s3.sh
../_common/nginx.sh
../_common/php.sh
../_common/mysql.sh
../_common/nodejs.sh
../_common/forever.sh
../_common/s3dl.sh


# nginx conf
echo "nginx.sh..."
. ./nginx.sh


# install repo
install_repo "$installDir" "$gitRepo"


# wordpress
echo "create database if not exists $mysqlDb" | mysql -uroot
# we need this file to be there immediately
mkdir -p $installDir/web/wp-content/uploads/x
s3cmd get --skip-existing s3://$s3Bucket/wp-content/uploads/x/style.css $installDir/web/wp-content/uploads/x/style.css
# we may have a problem when s3 pulls down a directory that wasnt previously given permissions...
chown -R www-data $installDir/web/wp-content/uploads
chmod -R +w $installDir/web/wp-content/uploads
# fetch wordpress db
node ../_common/s3dl/bin/loadsql.js -d $mysqlDb -b $s3Bucket/sql


chown -R www-data $dir/web/public-out


# secret configs
if [ -f $installDir/web/config.local.php ]; then
	rm $installDir/web/config.local.php
fi
gen_add_line_to_file "$installDir/web/config.local.php" '<?php' '<?php'
gen_add_line_to_file "$installDir/web/config.local.php" twitterAppKey "\$twitterAppKey='$twitterAppKey';"
gen_add_line_to_file "$installDir/web/config.local.php" twitterAppSecret "\$twitterAppSecret='$twitterAppSecret';"
if [ "$googleAnalyticsId" != "" ]; then
	gen_add_line_to_file "$installDir/web/config.local.php" googleAnalyticsId "\$googleAnalyticsId='$googleAnalyticsId';"
fi

# test cname
localhost_add_cname 'local.hopechapellongbeach.com'


# deploy hook service
IP=`public_ip`
echo "[{\"repo\":\"$installDir\",\"branch\":\"master\"}]" > "$installDir/hooky.json"
cd $startpwd/hooky
npmi
forever_run "./index.js -t $githubHookAuthToken -a $IP -c $installDir/hooky.json"
cd $startpwd

# until i fix multiple github hooks issue...
#gitsync_cron "$installDir" "master"


# bak sql
baksql_log=/var/log/hope_baksql.log
cron="0 3 * * * /usr/local/bin/node $sireDir/_common/s3dl/bin/baksql.js -d $mysqlDb -b $s3Bucket/sql >> $baksql_log 2>&1 #hope_bakSql"
crontab_add '#hope_bakSql' "$cron"


# s3 sync service
cd $sireDir/_common/s3dl
npmi
forever_run "$sireDir/_common/s3dl/index.js -d $installDir/web/wp-content/uploads -w /wp-content/uploads -b $s3Bucket/wp-content/uploads -p 9991,9900-9995,/etc/nginx/sites-available/hope"
cd $startpwd


# rotate logs
logrotate_log=$installDir/out/logrotate.log
nginx_access_log=`grep access_log /etc/nginx/sites-enabled/hope | head -n1 | awk '{print $2}' | tr -d ';'`
nginx_error_log=`grep error_log /etc/nginx/sites-enabled/hope | head -n1 | awk '{print $2}' | tr -d ';'`
cron="0 2 * * * /bin/bash $sireDir/bin/logrotate.sh 10 '$baksql_log' '$nginx_access_log' '$nginx_error_log' '$logrotate_log' 2>&1 >> '$logrotate_log' #hope_rotateLogs"
crontab_add '#hope_rotateLogs' "$cron"


