# nginx conf

acqadminAuth="admin:VMN6F/Mm19NV."
acqadminAuthFile="/etc/nginx/acqadmin_auth"

echo $acqadminAuth > $acqadminAuthFile

cat > /etc/nginx/sites-available/happiness <<FILE
server {
    listen       80;

    server_name fakem1.jewelmint.com m1.jewelmint.com track-m1.jewelmint.com fb.jewelmint.com start.jewelmint.com static-start.jewelmint.com start.stylemint.com start.shoemint.com start.intimint.com vip.jewelmint.com vip-dev.jewelmint.com;
    root   /var/www/m1.jewelmint.com;
    error_page  400      /400.php;
    autoindex off;

    # doesnt like "main"
    #access_log  /var/log/nginx/start_log.log main;
    access_log  /var/log/nginx/start_log.log;

    gzip on; # use gzip compression
    gzip_min_length 1100;
    gzip_buffers 4 8k; 
    gzip_proxied any; # enable proxy for the fcgi requests
    gzip_types text/plain text/css application/x-javascript text/javascript application/json; 

    # protection (we have no .htaccess)
    location ~ (/(app/|includes/|/pkginfo/|var/|report/config.xml)|/\.svn/|/.hta.+) {
        deny all;
    }

    # hide crons
    location ~ ^/crons {
        deny all;
    }

    # s3 webwrite
    location ~ ^/webwrite {
        if (!-f \$request_filename) {
            # 9991 = s3dl
            proxy_pass http://localhost:9991;
            break;
        }
    }

    # handle all .php files, /downloader and /report
    location ~ (\.php|/downloader/?|/report/?)\$ {
        if (\$request_uri ~ /(downloader|report)\$){ # no trailing /, redirecting
            rewrite  ^(.*)\$ \$1/ permanent;
        }
        fastcgi_index index.php;
        include /etc/nginx/fastcgi_params;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        if (-e \$request_filename) { # check if requested path exists
            fastcgi_pass $nginxBackend;
        }

    }

    # handle magento
    location /
    {
        # set expire headers
        if (\$request_uri ~* "\.(ico|css|js|gif|jpe?g|png)\$") {
            expires max;
        }
        # set fastcgi settings, not allowed in the "if" block
        include /etc/nginx/fastcgi_params;
        fastcgi_param SCRIPT_FILENAME \$document_root/index.php;
        fastcgi_param SCRIPT_NAME /index.php;
        # rewrite - if file not found, pass it to the backend
        if (!-f \$request_filename) {
            fastcgi_pass $nginxBackend;
            break;
        }
    }

    location ~ ^/k/acqadmin {
        auth_basic "Restricted";
        auth_basic_user_file $acqadminAuthFile;
        include /etc/nginx/fastcgi_params;
        fastcgi_param SCRIPT_FILENAME \$document_root/index.php;
        fastcgi_param SCRIPT_NAME /index.php;
        if (!-f \$request_filename) {
            fastcgi_pass $nginxBackend;
            break;
        }
    }
}

## a1
server {
    listen       80;

    server_name  fakea1.jewelmint.com a1.jewelmint.com a2.jewelmint.com;
    root   /var/www/a1.jewelmint.com/jewelmint-mktg;
    error_page  400      /400.php;
    autoindex off;

    # doesnt like "main"
    #access_log  /var/log/nginx/m1_log.log main;
    access_log  /var/log/nginx/m1_log.log;

    gzip on; # use gzip compression
    gzip_min_length 1100;
    gzip_buffers 4 8k; 
    gzip_proxied any; # enable proxy for the fcgi requests
    gzip_types text/plain text/css application/x-javascript text/javascript application/json; 

    # protection (we have no .htaccess)
    location ~ (/(app/|includes/|/pkginfo/|var/|report/config.xml)|/\.svn/|/.hta.+) {
        deny all;
    }

    # handle all .php files, /downloader and /report
    location ~ (\.php|/downloader/?|/report/?)\$ {
        if (\$request_uri ~ /(downloader|report)\$){ # no trailing /, redirecting
            rewrite  ^(.*)\$ \$1/ permanent;
        }
        fastcgi_index index.php;
        include /etc/nginx/fastcgi_params;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        if (-e \$request_filename) { # check if requested path exists
            fastcgi_pass $nginxBackend;
        }

    }

    # handle magento
    location /
    {
        # set expire headers
        if (\$request_uri ~* "\.(ico|css|js|gif|jpe?g|png)\$") {
            expires max;
        }
        # set fastcgi settings, not allowed in the "if" block
        include /etc/nginx/fastcgi_params;
        fastcgi_param SCRIPT_FILENAME \$document_root/index.php;
        fastcgi_param SCRIPT_NAME /index.php;
        # rewrite - if file not found, pass it to the backend
        if (!-f \$request_filename) {
            fastcgi_pass $nginxBackend;
            break;
        }
    }
}
FILE


rm /etc/nginx/sites-enabled/default 2> /dev/null
ln -f /etc/nginx/sites-available/happiness /etc/nginx/sites-enabled/happiness

/etc/init.d/nginx reload