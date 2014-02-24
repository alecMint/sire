
startpwd=`pwd`

. ../secrets

# modules
../_common/nginx.sh
../_common/php.sh
../_common/mysql.sh
../_common/nodejs.sh
../_common/forever.sh
../_common/wordpress.sh /var/www/hope/web


# nginx conf
. ./nginx.sh

# crons
. ./crons.sh

# repo
if [ ! -d /var/www/hope ]; then
  mkdir -p /var/www/hope
  git clone $hopeRepo /var/www/hope
fi
cd /var/www/hope
git checkout master
git pull origin master


# wordpress
echo 'create database if not exists wordpress' | mysql -uroot
mkdir /var/www/hope/web/wp-content/uploads
chown www-data /var/www/hope/web/wp-content/uploads
chmod +w /var/www/hope/web/wp-content/uploads


# test cname
localhost_add_cname 'local.hopechapellongbeach.com'


# deploy hook service
IP=`public_ip`
cd $startpwd/hooky
npmi
echo '[{"repo":"/var/www/hope","branch":"master"}]' > hooky.json
forever_run "./index.js -t $githubHookAuthToken -a $IP -c "`pwd`"/hooky.json"
cd $startpwd