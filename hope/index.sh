
startpwd=`pwd`

. ../secrets

# modules
../_common/s3.sh
../_common/nginx.sh
../_common/php.sh
../_common/mysql.sh
../_common/nodejs.sh
../_common/forever.sh


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
# we need this file to be there immediately
mkdir /var/www/hope/web/wp-content/uploads/x
s3cmd get s3://$hopeS3Bucket/wp-content/uploads/x/style.css /var/www/hope/web/wp-content/uploads/x/style.css
# we may have a problem when s3 pulls down a directory that wasnt previously given permissions...
chown -R www-data /var/www/hope/web/wp-content/uploads
chmod -R +w /var/www/hope/web/wp-content/uploads


# test cname
localhost_add_cname 'local.hopechapellongbeach.com'


# deploy hook service
IP=`public_ip`
cd $startpwd/hooky
npmi
echo '[{"repo":"/var/www/hope","branch":"master"}]' > hooky.json
forever_run "./index.js -t $githubHookAuthToken -a $IP -c "`pwd`"/hooky.json"
cd $startpwd

# s3 sync service
cd $startpwd/../_common/s3dl
npmi
forever_run "./index.js -d /var/www/hope/web/wp-content/uploads -w /wp-content/uploads -b sire-hope/wp-content/uploads"
cd $startpwd

# fetch wordpress data
node ../_common/s3dl/bin/loadsql.js -d wordpress -b sire-hope/sql

