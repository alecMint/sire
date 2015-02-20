
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


# deploy hook service
#IP=`public_ip`
#echo '[{"repo":"'$installDir'","branch":"master"}]' > $installDir'/hooky.json'
#cd $startpwd/hooky
#npmi
#forever_run "./index.js -t $githubHookAuthToken -a $IP -c $installDir/hooky.json"
#cd $startpwd

# until i fix multiple github hooks issue...
gitsync_cron "$installDir" "master"


# test cname
localhost_add_cname 'local.alechulce.com'


# rotate logs
cron="0 2 * * * /bin/bash $sireDir/bin/logrotate.sh 10 '$nginx_access_log' '$nginx_error_log' '$logrotate_log' 2>&1 >> '$logrotate_log' #$key_rotateLogs"
echo "installing crontab: $cron"
crontab_add '#$key_rotateLogs' "$cron"