#!/bin/bash
d=`dirname $0`
. $d/npmi.sh
. $d/util.sh

f=`which forever`
if [ "$f" == "" ];then
  npmi -g forever
else
  echo "forever installed already."
fi



p=`/usr/bin/realpath $d/../bin/foreverlogs.sh`
echo "forever cron $d"
echo "realpath $p"

crontab_add foreverlogs.sh "1 5 * * * $p 2>&1 > /dev/null"



