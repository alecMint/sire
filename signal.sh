#!/bin/bash
# Ex: ./signal.sh lucky-deploy
#


cd `dirname $0`
. ./collect_args.sh $@
module=${envs[0]}

. _deploy/config.sh
if [ -f _deploy/config.chef.sh ]; then
	. _deploy/config.chef.sh
fi
if [ "$serverNameOverride" ]; then serverName=$serverNameOverride; fi
if [ $aptUpdate == 0 ]; then args=' -na'; fi

if [ ! -d "$module" ]; then
	echo "Please supply a valid module name"
	exit 1
fi

echo "ssh ubuntu@$serverName \"sudo $sireDir/index.sh $module$args\""
ssh ubuntu@$serverName "sudo $sireDir/index.sh $module$args"

