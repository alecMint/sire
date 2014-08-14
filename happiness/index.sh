
#this is the entrance file for deploying marketing php and happiness
startpwd=`pwd`

# crons
. ./crons.sh

# nginx conf
. ./nginx.sh

# m1 repo
if [ ! -d /var/www/m1.jewelmint.com ]; then
  mkdir -p /var/www/m1.jewelmint.com
  git clone git@github.com:beachmint/user-a.git /var/www/m1.jewelmint.com
fi
cd /var/www/m1.jewelmint.com
git checkout prod
git pull origin prod

# a1 repo
if [ ! -d /var/www/a1.jewelmint.com/jewelmint-mktg ]; then
  mkdir -p /var/www/a1.jewelmint.com/jewelmint-mktg
  git clone git@github.com:beachmint/jewelmint-mktg.git /var/www/a1.jewelmint.com/jewelmint-mktg
fi
cd /var/www/a1.jewelmint.com/jewelmint-mktg
git checkout master
git pull origin master


# m1 test cname
localhost_add_cname 'fakem1.jewelmint.com'

# a1 test cname
localhost_add_cname 'fakea1.jewelmint.com'

# happiness
cd /var/www/m1.jewelmint.com/happiness
npmi
forever_run ./server.js -port $happinessPort

# s3 sync service
cd $startpwd/s3dl
npmi
forever_run "./index.js -d /var/www/m1.jewelmint.com/webwrite -b bm-marketing-web/webwrite"
cd $startpwd

# deploy hook service
IP=`public_ip`
echo '[{"repo":"/var/www/a1.jewelmint.com/jewelmint-mktg"},{"repo":"/var/www/m1.jewelmint.com/happiness","branch":"prod"}]' > '/var/www/m1.jewelmint.com/hooky.json'
cd $startpwd/hooky
npmi
forever_run "./index.js -t $githubHookAuthToken -a $IP -c /var/www/m1.jewelmint.com/hooky.json"
cd $startpwd
