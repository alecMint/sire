

if [ "`curl fakem1.jewelmint.com/hc.php`" != "OK" ]; then
  echo "web failed healthcheck"
else
  echo "web passed healthcheck"
fi

if [ "`/etc/init.d/nginx configtest 2>&1 | grep failed`" != "" ]; then
  echo "nginx conf failed"
else
  echo "nginx conf passed"
fi

if [ "`cat /var/www/hope/.git/config | grep -oP "${hopeRepo}$"`" != $hopeRepo ]; then
  echo "repo missing"
  exit 1
else
  echo "repo deployed"
fi