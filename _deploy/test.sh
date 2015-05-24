
if [ "`ssh ubuntu@$serverName 'echo "ok"'`" != "ok" ]; then
	echo "failed to ssh"
	exit 1
else
	echo "can ssh"
fi

if [ "`ssh ubuntu@$serverName 'git --version'`" == "" ]; then
	echo "git not installed"
	exit 1
else
	echo "git installed"
fi

if [ "`ssh ubuntu@$serverName "sudo cat /root/sire/.git/config | grep -oP "${sireRepo}$""`" != $sireRepo ]; then
	echo "sire repo missing"
	exit 1
else
	echo "sire repo deployed"
fi

t=`ssh ubuntu@$serverName "sudo cat /root/sire/secrets | grep githubHookAuthToken | head -n1 | grep -oP '\".*\"'"`
if [ "$t" != "\"$githubHookAuthToken\"" ]; then
	echo "config missing githubHookAuthToken"
	exit 1
else
	echo "config contains githubHookAuthToken"
fi

if [ "$machineSshKeyPublic" != '' ]; then
	t=`ssh ubuntu@$serverName "sudo cat /root/.ssh/id_rsa.pub 2>/dev/null"`
	if [ "$t" != "$machineSshKeyPublic" ]; then
		echo "machine public key missing"
		exit 1
	else
		echo "machine public key installed"
	fi
	t=`ssh ubuntu@$serverName "sudo cat /root/.ssh/id_rsa 2>/dev/null"`
	if [ "$t" != "$machineSshKeyPrivate" ]; then
		echo "machine private key missing"
		exit 1
	else
		echo "machine private key installed"
	fi
fi


echo ''
echo 'Example module deploy:'
echo "ssh ubuntu@$serverName 'sudo $sireDir/index.sh arrrr'"
echo ''

