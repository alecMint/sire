Sire
===
Deploys modules and supporting software (e.g. nginx, node, etc) to remote *nix servers. Fully tested on fresh Amazon EC2 Ubuntu instances (with the following ports open to TCP: 22, 80, 8000-8999, 9998). Other AMIs may require some tweaking.

Team effort with ma main man Ryan Day [github.com/soldair](github.com/soldair)



### Example launch
This example deploys the "hope" module (see hope/ dir in this repo). Once run, a wordpress site will be up and running with:
- Codebase deployed from https://github.com/fluffybunnies/hope
- SQL + uploads synced from previous instance via S3
- Githooks installed for instant release of codebase changes
- File watch hooks + crons set up to push DB/uploads to S3

Copy config.chef.example.sh to config.chef.sh inside ./_deploy and edit:
```bash
export ec2Cert='/Users/robthomas/.ssh/my-aws-private-key.pem'
export serverName='123.123.123.123' # or cname e.g. ec2-123-123-123-123.compute-1.amazonaws.com
export sshKey='/Users/robthomas/.ssh/id_rsa.pub'
export githubHookAuthToken='b926g...'
export twitterAppKey="HLXu..."
export twitterAppSecret="pNJi..."
export machineSshKeyPublic='ssh-rsa AAAAC4G...'
export machineSshKeyPrivate=$'-----BEGIN RSA PRIVATE KEY-----\nMIIFnAGB...'
```
Deploy sire to remote server (run this from sire repo root):
```bash
./index.sh _deploy
```
Deploy hope module to remote server:
```bash
./signal.sh hope
# same as:
# ssh ubuntu@123.123.123.123 'sudo /root/sire/index.sh hope'
```


### Example custom boot down (using hope)
This example uses the "hope" module to show how Sire may be used to to back up a wordpress site for seamless deployment to a new server.

```bash
node /root/sire/_common/s3dl/bin/baksql.js -d wordpress -b sire-hope/sql
node /root/sire/_common/s3dl/bin/shuv.js -d /var/www/hope/web/wp-content/uploads -b sire-hope/wp-content/uploads
crontab -r
killall node
# ec2-stop-instances
```


### To Do
- Fix issue where two forevers are launched on raptor deploy
	- Causes raptor to fail on deploy
- **Top Priority:** Set module-specific secrets
	- Instead of using global conf we have to keep updating
	- Think this over though, cuz really what we want to answer is where does chef inject
- Encaps _common/util.sh methods with parens instead of brackets to avoid var clobs
	- e.g. (+start with) rotate_logs2() => rotate_logs()
	- Test thoroughly though, the new shell may not behave as expected
- Figure out why /var/log/access.log is filling up + fix
	- Even though all nginx confs point to own logfile
- Solve issue with overflowing forever logs
	- /root/.forever/*
	- Consider installing cleanup cron on forever_start
- Secrets aren't updated if the key already exists
	- They probly should be
- Use arguments as alternative to config for _deploy module
	- If module == _deploy, source an arg-to-export file
	- Or consider alternative: pass path to alt config file. This could be done globally (ie not just for _deploy)
	- Add instructions to readme
- Package hooky and remove dups
- Fix issue where only one hooky can be running at once
	- Getting error: {"message":"Validation Failed","errors":[{"resource":"Hook","code":"custom","message":"Hook already exists on this repository"}],"documentation_url":"https://developer.github.com/v3/repos/hooks/#create-a-hook"}
	- Would be best to share a port. Can we configure octopie to set up multiple hooks at once?
- Fix faulty logic inside _deploy/index.sh where it checks for existence of local sire .git when it should check remote .git
	- Currently /root/sire is simply deleted and replaced with latest version. This could cause issues with submodule instantiation dependencies (e.g. _common/s3dl/node_modules)
- Make crontab easier to read with whitespace
- Cleanup /root/.forever/*.log
	- +Ship to s3
- Support _deploy config option: s3_logs
	- All logs will ship to target bucket when rotated
- Group rotate_logs
	- I.e. so that if you call it multiple times, it'll append to crontabs that have same timing if it exists


