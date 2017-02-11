#!/bin/bash
#
# install alminium and so on
#

# for mysql auto installation
export DEBIAN_FRONTEND=noninteractive

# install alminium
git clone -b "${ALM_VER}" https://github.com/ayapapa/alminium.git \
    ${ALM_HOME}/alminium
cd ${ALM_HOME}/alminium && ./smelt

# stop service for copying data
service apache2 stop

# save hostname
echo ${ALM_HOSTNAME} > /etc/opt/alminium/hostname

# save relative path
if [ "`echo ${ALM_RELATIVE_URL_ROOT} | cut -c 1`" = "/" ]
then
  echo ${ALM_RELATIVE_URL_ROOT} | cut -c 2- > /etc/opt/alminium/relative_path
else
  echo ${ALM_RELATIVE_URL_ROOT} > /etc/opt/alminium/relative_path
fi

# data persistence
date > /opt/alminium/initialized
cp -p /opt/alminium/initialized /opt/alminium/files/
cp -p /opt/alminium/initialized /var/opt/alminium/
cd /opt/alminium && tar czf ${ALM_HOME}/files.tar.gz ./files
cd /var/opt && tar czf ${ALM_HOME}/repo.tar.gz ./alminium
cd ${ALM_HOME}

# delete resouces
apt-get -y purge bc libmagickcore-dev libmagickwand-dev libmysqlclient-dev \
           libsqlite3-dev libssl-dev make g++
apt-get -y autoremove
apt-get -y autoclean
rm -r ${ALM_HOME}/alminium/{cache,docs,spec,test,jenkins,patch}

