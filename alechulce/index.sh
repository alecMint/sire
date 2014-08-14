
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
if [ ! -d /var/www/alechulce ]; then
  mkdir -p /var/www/alechulce
  git clone $alechulceRepo /var/www/alechulce
fi
cd /var/www/alechulce
git checkout master
git pull origin master


# test cname
localhost_add_cname 'local.alechulce.com'


# deploy hook service
IP=`public_ip`
cd $startpwd/hooky
npmi
echo '[{"repo":"/var/www/alechulce","branch":"master"}]' > hooky.json
forever_run "./index.js -t $githubHookAuthToken -a $IP -c "`pwd`"/hooky.json"
cd $startpwd