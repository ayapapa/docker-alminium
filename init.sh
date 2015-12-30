#!/bin/bash
#
# if not initialized, prepare initial data
#

# ALMinium's DB data
if [ ! -f /var/lib/mysql/initialized ]
then
  cd / && tar xzf /home/var-lib-mysql.tar.gz
fi

# ALMinium's app
if [ ! -f /opt/alminium/initialized ]
then
  cd / && tar xzf /home/opt-alminium.tar.gz
fi

# ALMinium's repo
if [ ! -f /var/opt/alminium/initialized ]
then
  cd / && tar xzf /home/var-opt-alminium.tar.gz
fi

# ALMinium's configs
if [ ! -f /etc/opt/alminium/initialized ]
then
  cd / && tar xzf /home/etc-opt-alminium.tar.gz
fi

# HOSTNAME
echo $ALM_HOSTNAME > /etc/opt/alminium/hostname

# RELATIVE_DIR
echo $ALM_RELATIVE_URL_ROOT > /etc/opt/alminium/relative_dir

