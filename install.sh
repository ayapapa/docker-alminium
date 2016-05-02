#!/bin/bash
#
# install alminium and so on
#

# for mysql auto installation
export DEBIAN_FRONTEND=noninteractive

# install alminium
git clone -b "$ALM_VER" https://github.com/ayapapa/alminium.git $ALM_HOME/alminium
cd $ALM_HOME/alminium && ./smelt

# stop service for copying data
service apache2 stop

# save hostname
echo $ALM_HOSTNAME > /etc/opt/alminium/hostname

# save relative path
if [ "`echo $ALM_SUBDIR | cut -c 1`" = "/" ]
then
  echo $ALM_RELATIVE_URL_ROOT | cut -c 2- > /etc/opt/alminium/relative_path
else
  echo $ALM_RELATIVE_URL_ROOT > /etc/opt/alminium/relative_path
fi

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
apt-get -y autoremove
apt-get -y autoclean

