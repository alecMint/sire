
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


if [ "`s3cmd 2>&1 | grep 'not found'`" != "" ]; then
	echo "s3cmd not installed"
	exit 1
else
	echo "s3cmd installed"
fi
