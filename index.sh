#!/bin/bash
# Ex: ./index.sh ace alechulce -na
# Skip `apt-get update`: -na
# Remote instance override: --target=ec2-54-176-178-234.us-west-1.compute.amazonaws.com
#

echo 'whoami: '`whoami`

aptUpdate=1
argi=0
for arg in "$@"; do
	target=`echo "$arg" | sed -n 's/^--target=\(.*\)/\1/p'`
	if [ "$target" != "" ]; then
		serverNameOverride=$target
	elif [ "$arg" == '-na' ]; then
		aptUpdate=0
	else
		envs[$argi]=$arg
		((argi++))
	fi
done
echo "envs: ${envs[@]}"
if [ "$serverNameOverride" ]; then echo "serverNameOverride: $serverNameOverride"; fi
echo "aptUpdate: $aptUpdate"


if [ -f /usr/bin/apt-get ]; then
	echo "we have apt-get"
	if [ $aptUpdate == 1 ]; then
		echo 'apt-get update...'
		apt-get update
		apt-get install --assume-yes curl build-essential realpath
	fi
	export DEBIAN_FRONTEND=noninteractive # shhh!
fi


if [ "`which realpath`" == "" ]; then
	echo "we dont have realpath, making one that works on directories" # e.g. from my mac
	realpath() {
		echo `cd "${1}";pwd`
	}
fi


refDir=`dirname $0`
refDir=`realpath $refDir`
echo "cd $refDir"
cd $refDir


if [ "$1" == "" ]; then
	echo "if you would like to deploy specific environment(s) please specify them as arguments"
else
	oneInvalid=0
	deployed=""
	for env in "${envs[@]}"; do
		if [ "$env" == '-na' ]; then
			echo '.'
		elif [ -d "$env" ]; then
			./_common/deploy.sh "$refDir/$env" "$serverNameOverride"
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
			./_common/test.sh "$refDir/$env" "$env" "$serverNameOverride"
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

