
startpwd=`pwd`

. ../secrets

# modules
#../_common/nginx.sh
#../_common/php.sh
../_common/mysql.sh
../_common/nodejs.sh
../_common/forever.sh


# set higher ulimit
profFile='/root/.profile'
setLimit='ulimit -Sn 4096'
if [ ! -f $profFile ]; then
	touch $profFile
	chmod 644 $profFile
fi
check=`grep "$setLimit" $profFile`
if [ "$check" == "" ]; then
	echo $setLimit >> $profFile
fi

# repo
if [ ! -d "$installDir" ]; then
  mkdir -p "$installDir"
  git clone $gitRepo "$installDir"
fi
cd "$installDir"
git checkout master
git pull origin master
npm install
forever_run ./server.js
gen_add_line_to_file '/etc/init/fabcompute' 'forever_run ./server.js' '+x'


# deploy hook service
IP=`public_ip`
echo '[{"repo":"'$installDir'","branch":"master"}]' > $installDir'/hooky.json'
cd $startpwd/hooky
npmi
forever_run "./index.js -t $githubHookAuthToken -a $IP -c $installDir/hooky.json"
gen_add_line_to_file '/etc/init/fabcompute' \
'forever_run "./index.js -t $githubHookAuthToken -a $IP -c $installDir/hooky.json"' \
'+x'
cd $startpwd


# BEGIN set file open limit
gen_add_line_to_file '/root/.profile' 'ulimit -Sn 4096' '0644'
gen_add_line_to_file '/etc/security/limits.conf' 'root soft nofile 4096'
sessionFiles=/etc/pam.d/common-session*
for f in $sessionFiles; do
	gen_add_line_to_file "$f" 'session required pam_limits.so'
done
# reboot...
#sudo reboot
# END set file open limit

