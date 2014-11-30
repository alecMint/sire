
startpwd=`pwd`

. ../secrets

# modules
../_common/nodejs.sh
../_common/forever.sh


# install repo
install_repo "$installDir" "$gitRepo"


# crons
chmod 0744 $installDir/crons/*
crontab_add 'cleanup.sh' "0 4 * * * $installDir/crons/cleanup.sh '$installDir'"


# deploy hook service
#IP=`public_ip`
#echo '[{"repo":"'$installDir'","branch":"master"}]' > $installDir'/hooky.json'
#cd $startpwd/hooky
#npmi
#forever_run "./index.js -t $githubHookAuthToken -a $IP -c $installDir/hooky.json"
#cd $startpwd

# until i fix multiple github hooks issue...
#gitsync_cron "$installDir" "master"


#secret configs
rm $installDir/config.local.json
gen_add_line_to_file "$installDir/config.local.json" '{'
if [ "$port" != "" ]; then
	gen_add_line_to_file "$installDir/config.local.json" port "\"port\": \"$port\""
fi
gen_add_line_to_file "$installDir/config.local.json" '}'


# start it up
#forever_run "$installDir/index.js"
