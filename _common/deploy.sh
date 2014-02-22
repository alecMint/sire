#!/bin/bash

. `dirname $0`/util.sh
. `dirname $0`/npmi.sh

cd $1

if [ -f ./config.sh ]; then
    . ./config.sh
    if [ -f ./config.chef.sh ]; then
    . ./config.chef.sh
    fi
fi
. ./index.sh
