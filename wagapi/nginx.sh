# nginx conf

nginxBackend="127.0.0.1:9000"

cat > /etc/nginx/sites-available/wagapi <<FILE
server {
	listen 80;

	server_name prod-api.wagwalking.com;
	root $installDir/public;
	autoindex off;

	access_log /var/log/nginx/wagapi_access.log;
	error_log /var/log/nginx/wagapi_error.log;

	gzip on; # use gzip compression
	gzip_min_length 1100;
	gzip_buffers 4 8k;
	gzip_proxied any; # enable proxy for the fcgi requests
	gzip_types text/plain text/css application/x-javascript text/javascript application/json;

	client_max_body_size 32M;

	# pass php to fastcgi
	location ~ \.php\$ {
		fastcgi_index index.php;
		include /etc/nginx/fastcgi_params;
		fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
		if (-e \$request_filename) { # check if requested path exists
			fastcgi_pass $nginxBackend;
		}
	}

	location / {
		# set expire headers for assets
		if (\$request_uri ~* "\.(ico|css|js|gif|jpe?g|png)\$") {
			expires max;
		}
		include /etc/nginx/fastcgi_params;
		fastcgi_param SCRIPT_FILENAME \$document_root/index.php;
		fastcgi_param SCRIPT_NAME /index.php;
		# pass nonexistants to index.php
		if (!-f \$request_filename) {
			fastcgi_pass $nginxBackend;
			break;
		}
	}
}

#server {
#	listen 443;
#
#	server_name www.luckymag.com luckymag.com m.luckymag.com promo.luckymag.com legacy.luckymag.com;
#	root $installDir/public;
#	autoindex off;
#
#	access_log /var/log/nginx/wagapi_access_ssl.log;
#	error_log /var/log/nginx/wagapi_error_ssl.log;
#
#	server_tokens off;
#	ssl on;
#	ssl_certificate $installDir/ssl/wagapi.pem;
#	ssl_certificate_key $installDir/ssl/wagapi-key.pem;
#
#	gzip on; # use gzip compression
#	gzip_min_length 1100;
#	gzip_buffers 4 8k;
#	gzip_proxied any; # enable proxy for the fcgi requests
#	gzip_types text/plain text/css application/x-javascript text/javascript application/json;
#
#	client_max_body_size 32M;
#
#	# pass php to fastcgi
#	location ~ \.php\$ {
#		fastcgi_index index.php;
#		include /etc/nginx/fastcgi_params;
#		fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
#		if (-e \$request_filename) { # check if requested path exists
#			fastcgi_pass $nginxBackend;
#		}
#	}
#
#	location / {
#		# set expire headers for assets
#		if (\$request_uri ~* "\.(ico|css|js|gif|jpe?g|png)\$") {
#			expires max;
#		}
#		include /etc/nginx/fastcgi_params;
#		fastcgi_param SCRIPT_FILENAME \$document_root/index.php;
#		fastcgi_param SCRIPT_NAME /index.php;
#		# pass nonexistants to index.php
#		#if (!-f \$request_filename) {
#			fastcgi_pass $nginxBackend;
#			break;
#		#}
#	}
#}
FILE
rm /etc/nginx/sites-enabled/default 2> /dev/null
ln -f /etc/nginx/sites-available/wagapi /etc/nginx/sites-enabled/wagapi

/etc/init.d/nginx reload
