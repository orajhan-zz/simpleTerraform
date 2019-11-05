#!/bin/bash

# Install and Configure MySQL database
mysqlRootPass="$1"

if [ -n "$1" ]; then
	echo "Error. Missing paramter"
	exit 1
fi

echo ' -> Removing previous mysql server installation'
systemctl stop mysqld.service && yum remove -y mysql-community-server && rm -rf /var/lib/mysql && rm -rf /var/log/mysqld.log && rm -rf /etc/my.cnf

echo ' -> Installing mysql server (community edition)'
yum localinstall -y https://dev.mysql.com/get/mysql57-community-release-el7-11.noarch.rpm
yum install -y mysql-community-server

echo ' -> Starting mysql server (first run)'
systemctl enable mysqld.service
systemctl start mysqld.service
tempRootDBPass="`grep 'temporary.*root@localhost' /var/log/mysqld.log | tail -n 1 | sed 's/.*root@localhost: //'`"

echo ' -> Setting up new mysql server root password'
systemctl stop mysqld.service
rm -rf /var/lib/mysql/*logfile*
systemctl start mysqld.service
mysqladmin -u root --password="$tempRootDBPass" password "$mysqlRootPass"
mysql -u root --password="$mysqlRootPass" -e <<-EOSQL
    DELETE FROM mysql.user WHERE User='';
    DROP DATABASE IF EXISTS test; 
    DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%'; 
    DELETE FROM mysql.user where user != 'mysql.sys'; 
    CREATE USER 'root'@'%' IDENTIFIED BY '${mysqlRootPass}';
    GRANT ALL ON *.* TO 'root'@'%' WITH GRANT OPTION;
    FLUSH PRIVILEGES;
EOSQL
systemctl status mysqld.service
echo " -> MySQL server installation completed, root password: $mysqlRootPass";