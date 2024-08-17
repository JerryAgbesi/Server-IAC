#!/bin/bash

sudo apt update -y && \
sudo apt install -y nginx && \
sudo mkdir -p /var/www/html && \
sudo chown -R ubuntu:ubuntu /var/www/html
echo "Terraform-demo instance is up" > /var/www/html/index.html

sudo chmod -R a+w debconf
sudo chmod a+w passwords.dat
sudo chmod a+w templates.dat

echo "mysql-server mysql-server/rootpassword password rootp@ss" | debconf-set-selections
echo "mysql-server mysql-server/root_password_again password rootp@ss" | debconf-set-selections

sudo DEBIAN_FRONTEND=noninteractive apt-get install -y mysql-server

sudo mysql_secure_installation <<EOF 
y 
rootp@ss
rootp@ss
y 
y 
y 
y 
EOF

mysql -uroot -p -e 'USE mysql; UPDATE `user` SET `Host`="%" WHERE `User`="root" AND `Host`="localhost"; DELETE FROM `user` WHERE `Host` != "%" AND `User`="root"; FLUSH PRIVILEGES;'

service mysql restart
