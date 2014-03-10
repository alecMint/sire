#!/bin/bash

apt-get -y install php5-fpm php5-cli php5-mysql

if [ "`grep 'listen = /var/run/php5-fpm.sock' /etc/php5/fpm/pool.d/www.conf`" != "" ]; then
  sed -i -e 's/\/var\/run\/php5-fpm.sock/127.0.0.1:9000/g' /etc/php5/fpm/pool.d/www.conf
fi

service php5-fpm restart