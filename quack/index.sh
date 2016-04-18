
startpwd=`pwd`

#. ../secrets

# modules
../_common/mysql.sh
../_common/nodejs.sh
../_common/forever.sh


# install repo
install_repo "$installDir" "$gitRepo"
if [ -f "$installDir/install.sh" ]; then
	cd "$installDir"
	./install.sh
	cd "$startpwd"
fi


# deploy hook service
#configure_hooky "$installDir" master $githubHookAuthToken
# until i fix multiple github hooks issue...
#gitsync_cron "$installDir" "master"



