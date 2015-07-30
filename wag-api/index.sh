# @todo: move most of this into wagapi/install.sh

. ../secrets

# modules
../_common/nginx.sh
../_common/php.sh


# laravel needs this...
/usr/bin/apt-get -y install php5-mcrypt
#if [ ! -d /etc/php5/conf.d ]; then mkdir /etc/php5/conf.d; fi
#ln -s /etc/php5/conf.d/mcrypt.ini /etc/php5/mods-available/mcrypt.ini
/usr/sbin/php5enmod mcrypt
service php5-fpm restart


# nginx conf
. ./nginx.sh


# install repo
install_repo "$installDir" "$gitRepo"
if [ -f "$installDir/install.sh" ]; then
	echo "running repo's install.sh"
	eval "$installDir/install.sh" -r
fi


# install composer dependencies
cd "$installDir"
/usr/bin/curl -sS https://getcomposer.org/installer | /usr/bin/php
/usr/bin/php composer.phar install
# also maybe: php artisan migrate

# give perms
chown -R www-data ./app/storage


#gitsync_cron "$installDir" "master"

