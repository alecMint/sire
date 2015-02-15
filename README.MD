Sire
===
Deploys modules and supporting software (e.g. nginx, node, etc) to remote *nix servers. Fully tested on fresh Amazon EC2 Ubuntu instances (with the following ports open to TCP: 22, 80, 8000-8999, 9998). Other AMIs may require some tweaking.

Team effort with ma main man Ryan Day (github.com/soldair)



### Example launch
This example deploys the "hope" module (see hope/ dir in this repo). Once run, a wordpress site will be up and running with:
- Codebase deployed from https://github.com/fluffybunnies/hope
- SQL + uploads synced from previous instance via S3
- Githooks installed for instant release of codebase changes
- File watch hooks + crons set up to push DB/uploads to S3

Copy config.chef.example.sh to config.chef.sh inside ./_deploy and edit:
```
export ec2Cert='/Users/ahulce/.ssh/mycert.pem'
export serverName='123.123.123.123' # or domain e.g. ec2-123-123-123-123.compute-1.amazonaws.com
export sshKey='/Users/ahulce/.ssh/id_rsa.pub'
export githubHookAuthToken='b926g...'
export twitterAppKey="HLXu..."
export twitterAppSecret="pNJi..."
export machineSshKeyPublic='ssh-rsa AAAAC4G...'
export machineSshKeyPrivate=$'-----BEGIN RSA PRIVATE KEY-----\nMIIFnAGB...'
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
- Fix faulty logic inside _deploy/index.sh where it checks for existence of local sire .git when it should check remote .git
- Make crontab easier to read with whitespace

