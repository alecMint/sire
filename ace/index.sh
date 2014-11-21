
startpwd=`pwd`

. ../secrets

# modules
../_common/nginx.sh
../_common/php.sh
../_common/mysql.sh
../_common/nodejs.sh
../_common/forever.sh


# repo
if [ ! -d "$installDir" ]; then
  mkdir -p "$installDir"
  git clone $gitRepo "$installDir"
fi
cd "$installDir"
git checkout master
git pull origin master
#npm install


# deploy hook service
IP=`public_ip`
echo '[{"repo":"'$installDir'","branch":"master"}]' > $installDir'/hooky.json'
cd $startpwd/hooky
npmi
forever_run "./index.js -t $githubHookAuthToken -a $IP -c $installDir/hooky.json"
cd $startpwd
