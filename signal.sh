#!/bin/bash
# Ex: ./signal.sh lucky-deploy
#

module=$1
noAptUpdate=
if [ "$2" == "-na" ]; then noAptUpdate=$2; fi

cd `dirname $0`

. _deploy/config.sh
if [ -f _deploy/config.chef.sh ]; then
	. _deploy/config.chef.sh
fi

if [ ! -d "$module" ]; then
	echo "Please supply a valid module name"
	exit 1
fi

echo "ssh ubuntu@$serverName 'sudo $sireDir/index.sh $module $noAptUpdate'"
ssh ubuntu@$serverName 'sudo $sireDir/index.sh $module $noAptUpdate'

