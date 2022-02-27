#!/bin/bash
#Todo
# [X] add choice is www or not as ServerAlias
# [X] Ask for letsencrypt SSL certificate creation
# [X] If not asked for www as server alias do not generate www cert
# [ ] Create NGINX VERSION
# [ ] Ask fpm or not
# [ ] Ask Php Version
#

EMAIL="email@domain.com"

if [ "$EUID" -ne 0 ]
    then
        echo "Please run as root"
        exit
    else
        if [ "$1" = '' ]
           then
               echo "Please enter the name for the virtual host"; exit
           else

 echo "Create folder for vhost files"
 mkdir -p /var/www/$1

 #want www Alias ?
 while true; do
     read -p "Do you want to add www alias? " php
     case $php in
         [Yy]* )
         SRVALIAS="ServerAlias www.$1";
         SSLALIAS="-d www.$1";
         break;;
         [Nn]* ) break;;
         * ) echo "Please answer yes/Y/y or no/N/n.";;
         esac
         done

 echo "Create vhost configuration file"
 sudo echo '<VirtualHost *:80>
 ServerName '$1'
 '$SRVALIAS'

 DocumentRoot '/var/www/$1'

 <Directory '/var/www/$1'>
        Options -Indexes +FollowSymLinks +MultiViews
        AllowOverride All
        Require all granted
 </Directory>

<FilesMatch \.php$>
        # 2.4.10+ can proxy to unix socket
        SetHandler "proxy:unix:/var/run/php/php7.4-fpm.sock|fcgi://localhost"
 </FilesMatch>

    ErrorLog ${APACHE_LOG_DIR}/'$1'_error.log
    CustomLog ${APACHE_LOG_DIR}/'$1'_access.log combined

 </VirtualHost>' > /etc/apache2/sites-available/$1.conf

 #Install SSL cert ?
 while true; do
     read -p "Do you want to generate and install SSL cert? " php
     case $php in
         [Yy]* )
              REQUIRED_PKG="python3-certbot-apache"
              PKG_OK=$(dpkg-query -W --showformat='${Status}\n' $REQUIRED_PKG|grep "install ok installed")
              echo Checking for $REQUIRED_PKG: $PKG_OK
              if [ "" = "$PKG_OK" ]; then
                echo "No $REQUIRED_PKG. Setting up $REQUIRED_PKG."
                sudo apt-get --yes install $REQUIRED_PKG
              fi
              certbot --apache --non-interactive --agree-tos -m $EMAIL -d $1 $SSLALIAS --redirect --expand;
         break;;
         [Nn]* ) break;;
         * ) echo "Please answer yes/Y/y or no/N/n.";;
     esac
 done

    sudo a2ensite $1
    sudo systemctl reload apache2
    echo "Your virtual host $1 has been set up"
       fi
fi
