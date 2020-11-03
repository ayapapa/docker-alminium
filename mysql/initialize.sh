#!/bin/bash

chown -R mysql:mysql /var/lib/mysql

service mysql start

# wait db available
OK=-1
while [ "${OK}" != "0" ]; do
  echo connecting to db
  mysql -e "SELECT user FROM user" mysql > /dev/null
  OK=$?
  sleep 5
done

echo "success to connect to mysql db"

# create alminium db
DB_EXIST=$(mysql -e "SHOW DATABASES" mysql | grep alminium)
if [ "${DB_EXIST}" = "" ]; then
  mysql -e "CREATE DATABASE alminium DEFAULT CHARACTER SET utf8"
fi

# add remote root user
mysql -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY 'alminium'"
mysql -e "GRANT PROCESS ON *.* TO 'root'@'%' IDENTIFIED BY 'alminium'"

# add remote alminium user
mysql -e "GRANT ALL PRIVILEGES ON alminium.* TO 'alminium'@'%' IDENTIFIED BY 'alminium'"

