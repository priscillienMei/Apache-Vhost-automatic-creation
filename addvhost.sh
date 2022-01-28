#!/bin/bash
if [ "$EUID" -ne 0 ]
    then 
        echo "Please run as root"
        exit
    else 
        if [ "$1" = '' ]
           then
               echo "Please enter the name for the virtual host"
           else
 sudo echo '<VirtualHost *:80>
 ServerName '$1'
 ServerAlias 'www.$1'
 DocumentRoot '/var/www/$1'
 
 <Directory '/var/www/$1'>
        Options -Indexes +FollowSymLinks +MultiViews
        AllowOverride All
        Require all granted
 </Directory>
 
<FilesMatch \.php$>
        # 2.4.10+ can proxy to unix socket
        SetHandler \"proxy:unix:/var/run/php/php7.4-fpm.sock|fcgi://localhost\"
 </FilesMatch>

    ErrorLog \${APACHE_LOG_DIR}/$1_error.log
    CustomLog \${APACHE_LOG_DIR}/$1_access.log combined

 </VirtualHost>' > /etc/apache2/sites-available/$1.conf
    sudo a2ensite $1
    sudo systemctl reload apache2
    echo "Your virtual host $1 has been set up"
       fi
fi
