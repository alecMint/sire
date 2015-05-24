
startpwd=`pwd`

. ../secrets

# modules
../_common/nodejs.sh
../_common/forever.sh


# install repo
install_repo "$installDir" "$gitRepo"


# crons
chmod 0744 $installDir/crons/*
crontab_add "$installDir/crons/cleanup.sh" "0 4 * * * $installDir/crons/cleanup.sh '$installDir'"


# deploy hook service
#configure_hooky "$installDir" master $githubHookAuthToken

# until i fix multiple github hooks issue...
#gitsync_cron "$installDir" "master"


# start it up
forever_run "$installDir/index.js --port 8001"
