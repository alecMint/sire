
. ../secrets

../_common/forever.sh

if [ ! -f /usr/local/bin/node ] && [ -f /usr/bin/node ]; then
	ln -s /usr/bin/node /usr/local/bin/node
fi
#if [ ! -f /usr/local/bin/forever ] && [ -f /usr/bin/forever ]; then
#if [ ! -f /usr/local/bin/forever ] && [ -f /usr/lib/node_modules/forever/bin/forever ]; then # /usr/bin/forever is a link
#	ln -s /usr/bin/forever /usr/lib/node_modules/forever/bin/forever
#fi

installDir=/var/www/platform-v2/current

configure_hooky $installDir develop $githubHookAuthToken 8013 $installDir/restart.sh
