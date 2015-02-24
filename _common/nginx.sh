#!/bin/bash

apt-get -y install nginx
/etc/init.d/nginx start
update-rc.d nginx defaults

# disable default log rotation
if [ -f /etc/logrotate.d/nginx ]; then
	contents=`cat /etc/logrotate.d/nginx | tr -d '\n'`
	if [ "$contents" != "" ]; then
		echo "disabling default nginx log rotation"
		mkdir -p /root/baks
		bakFile=/root/baks/logrotate.d_nginx.$(date +"%Y%m%d_%H%M%S")
		echo "placing current config in $bakFile"
		cp /etc/logrotate.d/nginx $bakFile
		echo '' > /etc/logrotate.d/nginx
	fi
fi
