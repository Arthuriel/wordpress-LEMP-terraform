#!/bin/bash
sudo su
apt update
apt upgrade -y
apt install nginx -y
# ufw enable 
# ufw allow 'Nginx HTTP'
apt install mysql-server -y
add-apt-repository universe
apt install php-fpm php-mysql -y
cd /var/www
curl -LO https://wordpress.org/latest.tar.gz
tar xzvf latest.tar.gz
rm latest.tar.gz
cd /var/www/wordpress
chown -R www-data:www-data /var/www/wordpress
#manual wordpress file creation in /etc/nginx/sites-available
cd /etc/nginx/sites-available
touch wordpress
echo "server {" > wordpress
echo "        listen 80;" >> wordpress
echo "        root /var/www/wordpress;" >> wordpress
echo "        index index.php index.html index.htm index.nginx-debian.html;" >> wordpress
echo "        server_name localhost;" >> wordpress
echo "" >> wordpress
echo "        location / {" >> wordpress
echo "                try_files \$uri \$uri/ =404;" >> wordpress
echo "        }" >> wordpress
echo "" >> wordpress
echo "        location ~ \.php$ {" >> wordpress
echo "                include snippets/fastcgi-php.conf;" >> wordpress
echo "                fastcgi_pass unix:/var/run/php/php7.4-fpm.sock;" >> wordpress
echo "        }" >> wordpress
echo "" >> wordpress
echo "        location ~ /\.ht {" >> wordpress
echo "                deny all;" >> wordpress
echo "        }" >> wordpress
echo "}" >> wordpress
#change port in default file
sed "s/listen 80 default_server;/listen 8080 default_server;/" /etc/nginx/sites-available/default -i
sed "s/listen [::]:80 default_server;/listen [::]:8080 default_server;/" /etc/nginx/sites-available/default -i
sed "s/listen 80 default_server;/listen 8080 default_server;/" /etc/nginx/sites-enabled/default -i
sed "s/listen [::]:80 default_server;/listen [::]:8080 default_server;/" /etc/nginx/sites-enabled/default -i
#create symbolic link from wordpress file
sudo ln -s /etc/nginx/sites-available/wordpress /etc/nginx/sites-enabled/
service nginx enable
service nginx restart
cp /var/www/wordpress/wp-config-sample.php /var/www/wordpress/wp-config.php
sed "s/database_name_here/wordpress/" /var/www/wordpress/wp-config.php -i
sed "s/username_here/wordpress/" /var/www/wordpress/wp-config.php -i
sed "s/password_here/wordpresskey1234/" /var/www/wordpress/wp-config.php -i
sed "s/localhost/10.0.3.4/" /var/www/wordpress/wp-config.php -i
#how to change ip in wp-config.php to dynamic?
