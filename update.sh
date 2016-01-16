#!/bin/bash
#
# update alminium
#

# ALMinium's DB data
if [ ! -f /var/lib/mysql/initialized ]
then
  cd / && tar xzf $ALM_HOME/db.tar.gz
elif [ "`cat /opt/alminium/initialized`" != "`cat /var/lib/mysql/initialized`" ]
then
  echo "update DB ..."
  cd /opt/alminium
  bundle exec rake db:migrate RAILS_ENV=production
  bundle exec rake redmine:plugins:migrate RAILS_ENV=production
  bundle exec rake tmp:cache:clear RAILS_ENV=production
  bundle exec rake tmp:sessions:clear RAILS_ENV=production
  cp -p /opt/alminium/initialized /var/lib/mysql/
  echo "...done"
fi

# attachement files
if [ ! -f /opt/alminium/files/initialized ]
then
  cd / && tar xzf $ALM_HOME/files.tar.gz
fi

# ALMinium's repo
if [ ! -f /var/opt/alminium/initialized ]
then
  cd / && tar xzf $ALM_HOME/repo.tar.gz
fi

# 不要でしょ！ALMinium's configs
#if [ ! -f /etc/opt/alminium/initialized ]
#then
#  cd / && tar xzf /home/etc-opt-alminium.tar.gz
#fi

# HOSTNAME
#echo $ALM_HOSTNAME > /etc/opt/alminium/hostname

# RELATIVE_DIR
#echo $ALM_RELATIVE_URL_ROOT > /etc/opt/alminium/relative_dir

cd $ALM_HOME

