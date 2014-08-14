
if [ "`/etc/init.d/nginx configtest 2>&1 | grep failed`" != "" ]; then
  echo "nginx conf failed"
  exit 1
else
  echo "nginx conf passed"
fi

if [ "`cat /var/www/alechulce/.git/config | grep -oP "${alechulceRepo}$"`" != $alechulceRepo ]; then
  echo "repo missing"
  exit 1
else
  echo "repo deployed"
fi

hc=`curl local.alechulce.com/hc.php`
if [ "$hc" != "OK" ]; then
  echo "web failed healthcheck"
  echo $hc
  exit 1
else
  echo "web passed healthcheck"
fi
