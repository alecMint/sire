#!/bin/bash

cd $1
if [ -f ./config.sh ]; then
    . ./config.sh
    if [ -f ./config.chef.sh ]; then
    . ./config.chef.sh
    fi
fi
if [ "$3" ]; then
	serverName=$3
fi

. ./test.sh
