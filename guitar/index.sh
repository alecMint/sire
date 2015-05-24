
startpwd=`pwd`

# modules
../_common/nginx.sh
../_common/php.sh


# nginx conf
. ./nginx.sh


# install repo
install_repo "$installDir" "$gitRepo"


# deploy hook service
#configure_hooky "$installDir" master $githubHookAuthToken

# until i fix multiple github hooks issue...
gitsync_cron "$installDir" "master"


# test cname
localhost_add_cname 'local.guitarlessonslongbeach.com'


# rotate logs
logrotate_log=/var/log/logrotate_guitar.log
rotate_logs 'guitar' "`accessLogLocation guitar`" "`errorLogLocation guitar`" -o "$logrotate_log"
rotate_logs 'guitar-logrotate' "$logrotate_log" -o "$logrotate_log" -t '@weekly'
