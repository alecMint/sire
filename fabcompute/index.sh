
startpwd=`pwd`

. ../secrets

# modules
#../_common/nginx.sh
#../_common/php.sh
../_common/mysql.sh
../_common/nodejs.sh
../_common/forever.sh


# reboot hook
sed -i '/exit 0/d' /etc/rc.local
gen_add_line_to_file '/etc/rc.local' '/root/sire/fabcompute/onstartup.sh'
gen_add_line_to_file '/etc/rc.local' 'exit 0'
#crontab_add 'FABCOMPUTE_REBOOT' '@reboot export FABCOMPUTE_REBOOT=1; /root/sire/index.sh fabcompute; unset FABCOMPUTE_REBOOT'


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


# deploy hook service
IP=`public_ip`
echo '[{"repo":"'$installDir'","branch":"master"}]' > $installDir'/hooky.json'
cd $startpwd/hooky
npmi
forever_run "./index.js -t $githubHookAuthToken -a $IP -c $installDir/hooky.json"
cd $startpwd


# BEGIN set file open limit
gen_add_line_to_file '/root/.profile' 'ulimit -Sn 4096' '0644'
#gen_add_line_to_file '/etc/security/limits.conf' 'root hard nofile 4096'
gen_add_line_to_file '/etc/security/limits.conf' 'root soft nofile 4096'
#gen_add_line_to_file '/etc/sysctl.conf' 'fs.file-max = 4096'
sessionFiles=/etc/pam.d/common-session*
for f in $sessionFiles; do
	gen_add_line_to_file "$f" 'session required pam_limits.so'
done
# reboot...
echo "FABCOMPUTE_REBOOT == $FABCOMPUTE_REBOOT"
if [ "$FABCOMPUTE_REBOOT" == "" ]; then
	sudo reboot
fi
# END set file open limit

