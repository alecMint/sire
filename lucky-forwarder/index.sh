
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
if [ -f "$installDir/install.sh" ]; then
	"$installDir/install.sh"
fi


# until i fix multiple github hooks issue...
#gitsync_cron "$installDir" "master"

