#!/bin/bash

apt-get install nginx
/etc/init.d/nginx start
update-rc.d nginx defaults
