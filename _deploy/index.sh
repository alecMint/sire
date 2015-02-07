#!/bin/bash
# temp solution for "sudo: unable to resolve host"
# ssh -i/Users/ahulce/.ssh/fabfitfun1.pem ubuntu@54.84.234.41
# echo "127.0.0.1    `hostname`" >> /etc/hosts

echo 'serverName: '$serverName
echo 'ec2Cert: '$ec2Cert

if [ "`ssh -oStrictHostKeyChecking=no ubuntu@$serverName 'echo "ok"'`" != "ok" ]; then
	echo 'copying ssh public key...'
	if [ -f "$sshKey" ]; then
		sshKey=`cat "$sshKey"`
	fi
	if [ "$ec2Cert" == "" ]; then
		echo "using ec2Cert"
		ssh -oStrictHostKeyChecking=no ubuntu@$serverName "echo '$sshKey' >> ~/.ssh/authorized_keys"
	else
		echo "using default identity file"
		ssh -oStrictHostKeyChecking=no -i"$ec2Cert" ubuntu@$serverName "echo '$sshKey' >> ~/.ssh/authorized_keys"
	fi
else
	echo 'user already has access to ec2, skipping cert copy'
fi

if [ $updateAptGet == 1 ]; then
	echo "updating apt-get..."
	ssh ubuntu@$serverName "sudo apt-get update"
fi
echo 'installing git...'
ssh ubuntu@$serverName "sudo apt-get -y install git-core"

echo "adding git's public key to known_hosts"
ssh ubuntu@$serverName "sudo ssh -oStrictHostKeyChecking=no git@github.com"

echo "setting up deployment repo ($sireBranch)..."
# @todo: fix this check, it needs to check remote directory, not local directory
if [ -d "$sireDir/.git" ]; then
	echo "updating existing repo"
	ssh ubuntu@$serverName "sudo git --git-dir=$sireDir/.git --work-tree=$sireDir checkout -f $sireBranch"
	ssh ubuntu@$serverName "sudo git --git-dir=$sireDir/.git --work-tree=$sireDir fetch"
	ssh ubuntu@$serverName "sudo git --git-dir=$sireDir/.git --work-tree=$sireDir pull origin $sireBranch"
else
	echo "cloning new repo"
	ssh ubuntu@$serverName "sudo rm -fr $sireDir"
	ssh ubuntu@$serverName "sudo git clone $sireRepo $sireDir"
	ssh ubuntu@$serverName "sudo git --git-dir=$sireDir/.git --work-tree=$sireDir checkout $sireBranch"
	ssh ubuntu@$serverName "sudo git --git-dir=$sireDir/.git --work-tree=$sireDir pull origin $sireBranch"
	ssh ubuntu@$serverName "sudo mkdir -p $sireDir/_common/s3dl/node_modules && sudo npm install --prefix $sireDir/_common/s3dl"
fi

# keep this here for (1) test.sh and (2) put at least something in secrets
echo 'copying github tokens...'
remote_config_add $serverName $sireDir/secrets githubHookAuthToken "$githubHookAuthToken"
#ssh ubuntu@$serverName "echo '{\"githubHookAuthToken\":\"$githubHookAuthToken\"}' | sudo tee $sireDir/config.local.json > /dev/null"

if [ "$awsAccessKey" != "" ]; then
	echo 'copying amazon tokens...'
	remote_config_add $serverName $sireDir/secrets awsAccessKey "$awsAccessKey"
	remote_config_add $serverName $sireDir/secrets awsAccessSecret "$awsAccessSecret"
	remote_config_add $serverName $sireDir/secrets awsRegion "$awsRegion"
fi

if [ "$googleAnalyticsId" != "" ]; then
	echo 'copying google analytics id...'
	remote_config_add $serverName $sireDir/secrets googleAnalyticsId "$googleAnalyticsId"
fi

if [ "$hopeTwitterAppKey" != "" ]; then
	echo 'copying service specific secrets...'
	remote_config_add $serverName $sireDir/secrets hopeTwitterAppKey "$hopeTwitterAppKey"
	remote_config_add $serverName $sireDir/secrets hopeTwitterAppSecret "$hopeTwitterAppSecret"
fi

if [ "$machineSshKeyPublic" != '' ]; then
	echo 'copying machine ssh keys...'
	if [ -f "$machineSshKeyPublic" ]; then
		machineSshKeyPublic=`cat "$machineSshKeyPublic"`
	fi
	if [ -f "$machineSshKeyPrivate" ]; then
		machineSshKeyPrivate=`cat "$machineSshKeyPrivate"`
	fi
	ssh ubuntu@$serverName "echo \"echo '$machineSshKeyPublic' > /root/.ssh/id_rsa.pub\" | sudo -s"
	ssh ubuntu@$serverName "echo \"echo '$machineSshKeyPrivate' > /root/.ssh/id_rsa\" | sudo -s"
	ssh ubuntu@$serverName "sudo chmod 0400 /root/.ssh/id_rsa"
fi

