#!/bin/bash
dir=`dirname $0`
cd $dir
. ../_common/util.sh


echo "about2: running = forever_is_running \"$1\""
running=`forever_is_running "$1"`
echo "running = $running"
if [ "$running" == "" ]; then
  echo $1" is not running!"
  forever_run "$1"
fi

