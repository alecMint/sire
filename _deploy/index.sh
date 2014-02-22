#!/bin/bash

echo 'serverName: '$serverName
echo 'ec2Cert: '$ec2Cert

if [ "`ssh ubuntu@$serverName 'echo "ok"'`" != "ok" ]; then
  echo 'copying ssh public key...'
  ssh -oStrictHostKeyChecking=no -i"$ec2Cert" ubuntu@$serverName "echo '$sshKey' >> ~/.ssh/authorized_keys"
else
  echo 'user already has access to ec2, skipping cert copy'
fi

echo 'installing git...'
if [ $updateAptGet == 1 ]; then
    ssh ubuntu@$serverName "sudo apt-get update"
fi
ssh ubuntu@$serverName "sudo apt-get -y install git-core"

echo 'setting up deployment repo...'
ssh ubuntu@$serverName "sudo rm -fr /root/sire"
ssh ubuntu@$serverName "sudo git clone $sireRepo /root/sire"

echo 'copying github tokens...'
# @todo: make a function for this
ssh ubuntu@$serverName "echo '{\"githubAuthTokenHooks\":\"$githubAuthTokenHooks\"}' | sudo tee /root/sire/config.local.json > /dev/null"
