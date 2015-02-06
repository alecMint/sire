
startpwd=`pwd`

. ../secrets

# modules
../_common/nginx.sh
../_common/php.sh
../_common/mysql.sh


# nginx conf
. ./nginx.sh


# create local db
echo "create database if not exists lucky_forwarder" | /usr/bin/mysql -uroot


# install repo
install_repo "$installDir" "$gitRepo"
if [ -f "$installDir/install.sh" ]; then
	echo "running repo's install.sh"
	"$installDir/install.sh"
fi


# until i fix multiple github hooks issue...
gitsync_cron "$installDir" "prod"

