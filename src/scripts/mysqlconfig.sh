#!/bin/bash
sudo su
apt update
apt upgrade -y
apt install mysql-server -y
# ufw enable
# ufw allow mysql
sed 's/127.0.0.1/0.0.0.0/' /etc/mysql/mysql.conf.d/mysqld.cnf -i
service mysql restart
mysql -e "CREATE DATABASE wordpress DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci;"
mysql -e "CREATE USER 'wordpress'@'localhost' IDENTIFIED BY 'wordpresskey1234';"
mysql -e "CREATE USER 'wordpress'@'10.0.2.4' IDENTIFIED BY 'wordpresskey1234';"
mysql -e "CREATE USER 'wordpress'@'%' IDENTIFIED BY 'wordpresskey1234';"
mysql -e "GRANT ALL ON wordpress.* TO 'wordpress'@'localhost';"
mysql -e "GRANT ALL ON wordpress.* to 'wordpress'@'10.0.2.4';"
mysql -e "GRANT ALL ON wordpress.* to 'wordpress'@'%';"