
. ../secrets


# modules
../_common/nodejs.sh


# install repo
branch=master
install_repo "$installDir" "$gitRepo" $branch
if [ -f "$installDir/install.sh" ]; then
	echo "running repo's install.sh"
	eval "$installDir/install.sh" -r
fi


#gitsync_cron "$installDir" "master"


forever_run "$installDir/index.js"


