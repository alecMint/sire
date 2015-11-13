# @todo: move most of this into wagapi/install.sh

. ../secrets

# modules
../_common/nginx.sh
../_common/php.sh
../_common/mysql.sh # @todo: only do this #ifOnDev
../_common/nodejs.sh # for utils + rotate_logs()


# laravel needs this...
/usr/bin/apt-get -y install php5-mcrypt
#if [ ! -d /etc/php5/conf.d ]; then mkdir /etc/php5/conf.d; fi
#ln -s /etc/php5/conf.d/mcrypt.ini /etc/php5/mods-available/mcrypt.ini
/usr/sbin/php5enmod mcrypt
/usr/sbin/service php5-fpm restart


# nginx conf
. ./nginx.sh


# install repo
branch=master
install_repo "$installDir" "$gitRepo" $branch
if [ -f "$installDir/install.sh" ]; then
	echo "running repo's install.sh"
	eval "$installDir/install.sh" -r
fi


# install composer dependencies
# cd "$installDir"
# /usr/bin/curl -sS https://getcomposer.org/installer | /usr/bin/php
# /usr/bin/php composer.phar install


# give php access
chown -R www-data "$installDir/app/storage"


#gitsync_cron "$installDir" "master"



# create db...
echo "create database if not exists $DB_DATABASE" | mysql

# create db user...
# @todo: only do this #ifOnDev - prod doesnt need to add db auth; pointed at rds
iptables -I INPUT -j ACCEPT
echo "grant all on *.* to '$DB_USER'@'%' identified by '$DB_PASS'; flush privileges" | mysql
sed -i 's/bind-address.*/bind-address = 0.0.0.0/' /etc/mysql/my.cnf
#/etc/init.d/mysqld restart # doesnt work on ubuntu 14.04
service mysql restart



# @todo: pushbash (chef/tools)

