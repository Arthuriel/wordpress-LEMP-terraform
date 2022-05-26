#!/bin/bash
sudo su
apt update
apt upgrade
apt install mysql-server
ufw enable
ufw allow mysql
sed 's/127.0.0.1/0.0.0.0/' /etc/mysq/mysql.conf.d/mysqld.cnf
service mysql restart
mysql host -e "CREATE DATABASE wordpress DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci;"
mysql host -e "CREATE USER 'wordpress'@'localhost' IDENTIFIED BY 'wordpresskey1234';"
mysql host -e "CREATE USER 'wordpress'@'10.1.0.4' IDENTIFIED BY 'wordpresskey1234';"
mysql host -e "CREATE USER 'wordpress'@'%' IDENTIFIED BY 'wordpresskey1234';"
mysql host -e "GRANT ALL ON wordpress.* TO 'wordpress'@'localhost';"
mysql host -e "GRANT ALL ON wordpress.* to 'wordpress'@'10.1.0.4';"
mysql host -e "GRANT ALL ON wordpress.* to 'wordpress'@'%';"