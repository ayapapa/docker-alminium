#!/bin/bash

service mysql start

# wait db available
OK=-1
until [ "${OK}" != "0" ]; do
  echo connecting to db
  mysql -e "SELECT user FROM user" mysql
  OK=$?
  sleep 5
done

echo "success to connect to mysql db"

# add remote alminium user
MYSQL_USERS=$(mysql -e "SELECT user, host FROM user" mysql)
if [ "$(echo ${MYSQL_USERS} | grep alminium | grep %)" = "" ]; then
  mysql -e "GRANT ALL PRIVILEGES ON alminium.* TO 'alminium'@'%' IDENTIFIED BY 'alminium'"
fi

# keep running this docker
sleep infinity

