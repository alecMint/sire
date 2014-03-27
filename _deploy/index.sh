#!/bin/bash

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
ssh ubuntu@$serverName "sudo rm -fr /root/sire"
ssh ubuntu@$serverName "sudo git clone $sireRepo /root/sire"

echo 'copying github tokens...'
remote_config_add $serverName /root/sire/secrets githubHookAuthToken "$githubHookAuthToken"
#ssh ubuntu@$serverName "echo '{\"githubHookAuthToken\":\"$githubHookAuthToken\"}' | sudo tee /root/sire/config.local.json > /dev/null"

echo 'copying amazon tokens...'
remote_config_add $serverName /root/sire/secrets awsAccessKey "$awsAccessKey"
remote_config_add $serverName /root/sire/secrets awsAccessSecret "$awsAccessSecret"

echo 'copying service specific secrets...'
remote_config_add $serverName /root/sire/secrets hopeTwitterAppKey "$hopeTwitterAppKey"
remote_config_add $serverName /root/sire/secrets hopeTwitterAppSecret "$hopeTwitterAppSecret"
