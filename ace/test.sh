
if [ "`/etc/init.d/nginx configtest 2>&1 | grep failed`" != "" ]; then
  echo "nginx conf failed"
  exit 1
else
  echo "nginx conf passed"
fi


if [ "`cat /var/www/scripts/.git/config | grep -oP "${gitRepo}$"`" != $gitRepo ]; then
  echo "repo missing"
  exit 1
else
  echo "repo deployed"
fi
