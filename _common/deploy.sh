#!/bin/bash

dir=`dirname $0`
. $dir/../_deploy/config.sh # for $sireDir et al
. $dir/util.sh
. $dir/npmi.sh

cd $1

if [ -f ./config.sh ]; then
    . ./config.sh
    if [ -f ./config.chef.sh ]; then
    . ./config.chef.sh
    fi
fi
if [ "$2" ]; then
	serverName=$2
fi
if [ "$3" ]; then
	branch=$3
fi

. ./index.sh
