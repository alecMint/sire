
hc=`curl local.hopechapellongbeach.com/hc.php`
if [ "$hc" != "OK" ]; then
  echo "web failed healthcheck"
  echo $hc
  exit 1
else
  echo "web passed healthcheck"
fi

if [ "`/etc/init.d/nginx configtest 2>&1 | grep failed`" != "" ]; then
  echo "nginx conf failed"
  exit 1
else
  echo "nginx conf passed"
fi

if [ "`cat /var/www/hope/.git/config | grep -oP "${guitarRepo}$"`" != $guitarRepo ]; then
  echo "repo missing"
  exit 1
else
  echo "repo deployed"
fi
