
if [ "`/etc/init.d/nginx configtest 2>&1 | grep failed`" != "" ]; then
	echo "nginx conf failed"
	exit 1
else
	echo "nginx conf passed"
fi


if [ "`cat ${installDir}/.git/config | grep -oP "${gitRepo}$"`" != $gitRepo ]; then
	echo "repo missing"
	exit 1
else
	echo "repo deployed"
fi


if [ ! "`echo "select convert_tz('2015-11-11 12:00:00', 'America/Los_Angeles', 'America/New_York');" | mysql -uroot | grep '2015-11-11 12:00:00' 2>/dev/null`" ]; then
	>&2 echo 'mysql timezone data failed to install'
	exit 1
else
	echo 'mysql timezone data installed'
fi


if [ ! -f "$installDir/config.local.php" ]; then
	>&2 echo 'failed to deploy chef config'
	exit 1
else
	echo 'chef config deployed'
fi


# @todo: test mysql connection
