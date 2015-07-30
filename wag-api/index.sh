
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

#gitsync_cron "$installDir" "master"

