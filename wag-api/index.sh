
. ../secrets

# modules
../_common/nginx.sh
../_common/php.sh


# nginx conf
. ./nginx.sh


# install repo
install_repo "$installDir" "$gitRepo"
if [ -f "$installDir/install.sh" ]; then
	echo "running repo's install.sh"
	eval "$installDir/install.sh" -r
fi


# @todo: move this to wagapi/install.sh
php "$installDir/composer.phar" install
# also maybe: php artisan migrate


#gitsync_cron "$installDir" "master"

