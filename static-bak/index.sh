
. ../secrets

# modules
../_common/nginx.sh
../_common/php.sh
../_common/s3.sh


# nginx conf
# in repo/install/config.nginx.sh
#. ./nginx.sh


# install repo
install_repo "$installDir" "$gitRepo"
if [ -f "$installDir/install.sh" ]; then
	echo "running repo's install.sh"
	eval "'$installDir/install.sh' -r"
fi

gitsync_cron "$installDir" "master"

