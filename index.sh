#!/bin/bash

if [ "$1" == "_deploy" ] || [ "$1" == "_deploy/" ]; then
  if [ "`which realpath`" == "" ]; then
    realpath() {
      echo `cd "${1}";pwd`
    }
  fi
else
  apt-get update
  export DEBIAN_FRONTEND=noninteractive # shhh!
  apt-get install --assume-yes curl build-essential realpath
fi

refDir=`dirname $0`
refDir=`realpath $refDir`
cd $refDir


if [ "$1" == "" ]; then
  echo "if you would like to deploy specific environment(s) please specify them as arguments"
else
  oneInvalid=0
  deployed=""
  for env in "$@"; do
    if [ -d "$env" ]; then
      ./_common/deploy.sh "$refDir/$env"
      deployed=$deployed"$env "
    else
      echo "$env is not a valid deploy name"
      oneInvalid=1
    fi
  done
  if [ $oneInvalid == 1 ]; then
    ls -d */ | grep -v _common
    exit 1
  fi
  for env in $deployed; do
    echo "testing $env"
    if [ -f "$env"/test.sh ]; then
      ./_common/test.sh "$refDir/$env" "$env"
      eCode=$?
      if [ "$eCode" != "0" ]; then
        echo "$env"/test.sh" failed: $eCode"
        exit 1
      fi
      echo "$env passed!"
    else
      echo "$env"/test.sh" does not exist"
    fi
  done
fi
