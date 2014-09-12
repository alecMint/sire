
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

# repo
if [ ! -d /var/www/migrate-wordpress ]; then
  mkdir -p /var/www/migrate-wordpress
  git clone $fabfitfunRepo /var/www/migrate-wordpress
fi
cd /var/www/migrate-wordpress
git checkout master
git pull origin master


# test cname
localhost_add_cname 'local.fffdev-migrate-wordpress.com'


# deploy hook service
IP=`public_ip`
echo '[{"repo":"/var/www/migrate-wordpress","branch":"master"}]' > '/var/www/migrate-wordpress/hooky.json'
cd $startpwd/hooky
npmi
forever_run "./index.js -t $githubHookAuthTokenFabFitFun -a $IP -c /var/www/migrate-wordpress/hooky.json"
cd $startpwd