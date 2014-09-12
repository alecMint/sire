
startpwd=`pwd`

. ../secrets

# modules
../_common/nginx.sh
../_common/php.sh
../_common/mysql.sh
../_common/nodejs.sh
../_common/forever.sh


# nginx conf
. ./nginx.sh

webDir='/var/www/migrate-wordpress'

# repo
if [ ! -d "$webDir" ]; then
  mkdir -p "$webDir"
  git clone $fabFitFunMigrateWordpressRepo "$webDir"
fi
cd "$webDir"
git checkout master
git pull origin master


# test cname
localhost_add_cname 'local.fffdev-migrate-wordpress.com'


# deploy hook service
IP=`public_ip`
echo '[{"repo":"'$webDir'","branch":"master"}]' > $webDir'/hooky.json'
cd $startpwd/hooky
npmi
forever_run "./index.js -t $githubHookAuthToken -a $IP -c $webDir/hooky.json"
cd $startpwd