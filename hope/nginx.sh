# nginx conf

cat > /etc/nginx/sites-available/hope <<FILE
server {
    listen 80;

    server_name hopechapellongbeach.com local.hopechapellongbeach.com;
    root /var/www/hope/web;
    autoindex off;

    access_log /var/log/nginx/test_log.log;

    gzip on; # use gzip compression
    gzip_min_length 1100;
    gzip_buffers 4 8k; 
    gzip_proxied any; # enable proxy for the fcgi requests
    gzip_types text/plain text/css application/x-javascript text/javascript application/json; 

    # s3 webwrite
    location ~ ^/wp-content/uploads {
        if (!-f \$request_filename) {
            # 9991 = s3dl
            proxy_pass http://localhost:9991;
            break;
        }
    }

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
FILE
rm /etc/nginx/sites-enabled/default 2> /dev/null
ln -f /etc/nginx/sites-available/hope /etc/nginx/sites-enabled/hope

/etc/init.d/nginx reload
