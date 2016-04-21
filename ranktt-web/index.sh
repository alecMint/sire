
startpwd=`pwd`

. ../secrets

# modules
../_common/nodejs.sh
../_common/forever.sh


# nginx conf
#. ./nginx.sh


# install repo
install_repo "$installDir" "$gitRepo"


# deploy hook service
#configure_hooky "$installDir" master $githubHookAuthToken
# until i fix multiple github hooks issue...
gitsync_cron "$installDir" "master"


#secret configs
#if [ -f $installDir/config.local.json ]; then rm $installDir/config.local.json; fi
#gen_add_line_to_file "$installDir/config.local.json" '{'
#gen_add_line_to_file "$installDir/config.local.json" awsAccessKey "\"awsAccessKey\": \"$awsAccessKey\""
#gen_add_line_to_file "$installDir/config.local.json" awsAccessSecret ",\"awsAccessSecret\": \"$awsAccessSecret\""
#gen_add_line_to_file "$installDir/config.local.json" awsRegion ",\"awsRegion\": \"$awsRegion\""
#gen_add_line_to_file "$installDir/config.local.json" '}'


forever_run "$installDir/index.js"

