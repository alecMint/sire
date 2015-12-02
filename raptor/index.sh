
. ../secrets


# modules
../_common/nodejs.sh
../_common/forever.sh


# install repo
branch=master
install_repo "$installDir" "$gitRepo" $branch
if [ -f ./chef-config.sh ]; then ./chef-config.sh; fi # before repo/install.sh in case it needs it or wants to modify it
if [ -f "$installDir/install.sh" ]; then
	echo "running repo's install.sh"
	eval "$installDir/install.sh" -r
fi


#gitsync_cron "$installDir" "master"


forever_run "$installDir/index.js"


