#!/bin/bash

dir=`dirname $0`
. $dir/../_deploy/config.sh # for $installDir et al
. $dir/util.sh
. $dir/npmi.sh

cd $1

if [ -f ./config.sh ]; then
    . ./config.sh
    if [ -f ./config.chef.sh ]; then
    . ./config.chef.sh
    fi
fi
. ./index.sh

echo ''
echo "ssh ubuntu@$serverName"
echo ''