#!/bin/bash
# temp solution for "sudo: unable to resolve host"
# ssh -i/Users/ahulce/.ssh/fabfitfun1.pem ubuntu@54.84.234.41
# echo "127.0.0.1    `hostname`" >> /etc/hosts

echo 'serverName: '$serverName
echo 'ec2Cert: '$ec2Cert

if [ "`ssh ubuntu@$serverName 'echo "ok"'`" != "ok" ]; then
	echo 'copying ssh public key...'
	ssh -oStrictHostKeyChecking=no -i"$ec2Cert" ubuntu@$serverName "echo '$sshKey' >> ~/.ssh/authorized_keys"
else
	echo 'user already has access to ec2, skipping cert copy'
fi

if [ $updateAptGet == 1 ]; then
	echo "updating apt-get..."
	ssh ubuntu@$serverName "sudo apt-get update"
fi
echo 'installing git...'
ssh ubuntu@$serverName "sudo apt-get -y install git-core"

echo 'setting up deployment repo...'
ssh ubuntu@$serverName "sudo rm -fr $sireDir"
ssh ubuntu@$serverName "sudo git clone $sireRepo $sireDir"

echo 'copying github tokens...'
remote_config_add $serverName $sireDir/secrets githubHookAuthToken "$githubHookAuthToken"
#ssh ubuntu@$serverName "echo '{\"githubHookAuthToken\":\"$githubHookAuthToken\"}' | sudo tee $sireDir/config.local.json > /dev/null"

echo 'copying amazon tokens...'
remote_config_add $serverName $sireDir/secrets awsAccessKey "$awsAccessKey"
remote_config_add $serverName $sireDir/secrets awsAccessSecret "$awsAccessSecret"

echo 'copying service specific secrets...'
remote_config_add $serverName $sireDir/secrets hopeTwitterAppKey "$hopeTwitterAppKey"
remote_config_add $serverName $sireDir/secrets hopeTwitterAppSecret "$hopeTwitterAppSecret"

if [ "$machineSshKeyPublic" != '' ]; then
	echo 'copying machine ssh keys...'
	ssh ubuntu@$serverName "echo \"echo '$machineSshKeyPublic' > /root/.ssh/id_rsa.pub\" | sudo -s"
	ssh ubuntu@$serverName "echo \"echo '$machineSshKeyPrivate' > /root/.ssh/id_rsa\" | sudo -s"
fi

