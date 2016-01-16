#!/bin/bash
#
# install alminium and so on
#

# install siminium
git clone -b docker-dev https://github.com/ayapapa/alminium.git $ALM_HOME/alminium
cd $ALM_HOME/alminium && sudo -E ./smelt

# stop service for copying data
service apache2 stop

# log setting
mv -f /opt/alminium/log /var/log/alminium
ln -s /var/log/alminium /opt/alminium/log

# data persistence
date > /opt/alminium/initialized
cp -p /opt/alminium/initialized /opt/alminium/files/
cp -p /opt/alminium/initialized /var/opt/alminium/
cp -p /opt/alminium/initialized /var/lib/mysql/
tar czf $ALM_HOME/db.tar.gz /var/lib/mysql
tar czf $ALM_HOME/files.tar.gz /opt/alminium/files
tar czf $ALM_HOME/repo.tar.gz /var/opt/alminium

# delete dev resouces
apt-get -y purge libmagickcore-dev libmagickwand-dev libmysqlclient-dev libsqlite3-dev libssl-dev ruby2.1-dev wget make g++
sudo apt-get -y autoremove
sudo apt-get -y autoclean

