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

# keep running this docker
sleep infinity
