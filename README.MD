Sire
===
Deploys software to remote *nix servers. Fully tested on fresh Amazon EC2 Ubuntu instances. Other AMIs may require some tweaking.

Team effort with ma main man Ryan Day (github.com/soldair)


### To Do
- Package hooky and remove dups
- Update _common/util.sh to use $sireDir as passed arg instead of hardcoded $dir
- Fix issue where only one hooky can be running at once due to port conflict


### Example boot down (using hope)
```
node /root/sire/_common/s3dl/bin/baksql.js -d wordpress -b sire-hope/sql
node /root/sire/_common/s3dl/bin/shuv.js -d /var/www/hope/web/wp-content/uploads -b sire-hope/wp-content/uploads
crontab -r
killall node
```


### Example launch (using hope)
Copy config.sh to config.chef.sh inside ./_deploy and edit:
```
export updateAptGet=1
export ec2Cert='/Users/ahulce/.ssh/mycert.pem'
export serverName='54.198.208.221' # or domain e.g. ec2-54-84-227-188.compute-1.amazonaws.com
export sshKey='ssh-rsa AAAAB3...'
export githubHookAuthToken='a713c...'
export hopeTwitterAppKey="HFUe..."
export hopeTwitterAppSecret="kMBn..."
export awsRegion='us-east-1'
export machineSshKeyPublic='ssh-rsa AAAAB3N...'
export machineSshKeyPrivate=$'-----BEGIN RSA PRIVATE KEY-----\nMIIEpAIB...'
```
Deploy sire to remote server (run this locally):
```
./index.sh _deploy
```
Deploy hope module on remote server (run this remotely):
```
/root/sire/index.sh hope
```
