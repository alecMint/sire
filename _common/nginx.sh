#!/bin/bash

apt-get -y install nginx
/etc/init.d/nginx start
update-rc.d nginx defaults
