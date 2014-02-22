
# m1
#   make sure acqadmin is protected
#   make sure crons is protected
#
echo "checking m1 hc"
#hc=`curl -m10 fakem1.jewelmint.com/hc.php`
#echo "result: $hc"
#if [ "$hc" != "OK" ]; then
#  echo "failed m1 hc"
#  exit 1
#fi

echo "checking m1 acqadmin auth"
hc=`curl -v fakem1.jewelmint.com/k/acqadmin 2>&1 | head -n10 | grep "HTTP/1.1 401 Unauthorized"`
if [ "$hc" == "" ]; then
  echo "failed m1 acqadmin auth"
  exit 1
fi

echo "checking m1 hide /crons"
hc=`curl -v fakem1.jewelmint.com/crons 2>&1 | head -n10 | grep "HTTP/1.1 403 Forbidden"`
if [ "$hc" == "" ]; then
  echo "failed m1 hide /crons"
  exit 1
fi


# a1
#
echo "checking a1 hc"
hc=`curl -m10 fakea1.jewelmint.com/hc.txt`
echo "result: $hc"
if [ "$hc" != "OK" ]; then
  echo "failed a1 hc"
  exit 1
fi


# /mnt
echo "checking /mnt/logs"
if [ ! -d /mnt/logs ]; then
  echo "/mnt/logs is not a dir"
  exit 1
fi


# nginx conf
echo "checking nginx conf"
hc=`/etc/init.d/nginx configtest 2>&1 | grep failed`
if [ "$hc" != "" ]; then
  echo "nginx conf failed"
  /etc/init.d/nginx configtest
  exit 1
fi


# happiness needs to be namesakely
#
echo "checking happiness hc"
hc=`curl localhost:$happinessPort/ok`
echo "result: $hc"
if [ "$hc" != "OK" ]; then
  echo "failed happiness hc"
  exit 1
fi

echo "checking amint"
#hc=`curl -v localhost:$happinessPort/wefwefwefefewf 2>&1 | head -n10 | grep "HTTP/1.1 404 Not Found"`
hc=`curl -v localhost:$happinessPort/amint/1.js 2>&1 | head -n10 | grep "HTTP/1.1 404 Not Found"`
if [ "$hc" != "" ]; then
  echo "failed happiness amint"
  exit 1
fi
