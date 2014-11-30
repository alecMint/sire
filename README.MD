Sire
===
Deploys software to remote *nix servers. Fully tested on fresh Amazon EC2 Ubuntu instances. Other AMIs may require some tweaking.

Team effort with ma main man Ryan Day (github.com/soldair)



### Example launch
This example deploys the "hope" module (hope/ dir in this repo). Once run, a wordpress site will be up and running.
- Codebase deployed from https://github.com/fluffybunnies/hope
- SQL + uploads synced from previous instance via S3
- Githooks installed for instant release of codebase changes

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


### Example custom boot down (using hope)
This example uses the "hope" module to show how Sire may be used to to back up a wordpress site for seamless deployment to a new server.

```
node /root/sire/_common/s3dl/bin/baksql.js -d wordpress -b sire-hope/sql
node /root/sire/_common/s3dl/bin/shuv.js -d /var/www/hope/web/wp-content/uploads -b sire-hope/wp-content/uploads
crontab -r
killall node
```


### To Do
- Package hooky and remove dups
- Fix issue where only one hooky can be running at once due to port conflict
