
startpwd=`pwd`

. ../secrets

# modules
../_common/nginx.sh
../_common/php.sh
../_common/mysql.sh


# nginx conf
. ./nginx.sh


# install repo
install_repo "$installDir" "$gitRepo"


# wordpress
echo "create database if not exists $mysqlDb charset=utf8mb4 collate=utf8mb4_unicode_ci" | mysql -uroot
# perms
chown -R www-data $installDir/web/wp-content/uploads
chmod -R +w $installDir/web/wp-content/uploads
# @todo: configure intial sql


# deploy hook service
#configure_hooky "$installDir" master $githubHookAuthToken
# until i fix multiple github hooks issue...
gitsync_cron "$installDir" "master"




