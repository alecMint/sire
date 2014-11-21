
startpwd=`pwd`

# modules
../_common/nginx.sh
../_common/php.sh


# nginx conf
. ./nginx.sh

# repo
if [ ! -d /var/www/guitar ]; then
  mkdir -p /var/www/guitar
  git clone $guitarRepo /var/www/guitar
fi
cd /var/www/guitar
git fetch
git checkout master
git pull origin master


# test cname
localhost_add_cname 'local.guitarlessonslongbeach.com'
