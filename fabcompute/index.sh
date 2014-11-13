
startpwd=`pwd`

. ../secrets

# modules
#../_common/nginx.sh
#../_common/php.sh
../_common/mysql.sh
../_common/nodejs.sh
../_common/forever.sh


# init boot hook
gen_add_line_to_file '/etc/init/fabcompute' 'echo "init fabcompute"' '+x'
gen_add_line_to_file '/etc/init/fabcompute' '/root/sire/index.sh fabcompute -r'



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
gen_add_line_to_file '/etc/security/limits.conf' 'root soft nofile 4096'
sessionFiles=/etc/pam.d/common-session*
for f in $sessionFiles; do
	gen_add_line_to_file "$f" 'session required pam_limits.so'
done
# reboot...
reboot=1
echo "GETTING OPTS..."
while getopts 'r' opt; do
	echo "OPTS..."
	echo $opt
	echo $OPTARG
done
#sudo reboot
# END set file open limit

