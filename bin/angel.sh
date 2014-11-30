#!/bin/bash
dir=`dirname $0`
cd $dir
. ../_common/util.sh

#echo "angel.sh \"$1\" "`date`
running=`forever_is_running "$1"`
if [ "$running" == "" ]; then
  echo $1" is not running!"
  forever_run "$1"
fi

