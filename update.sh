#!/bin/bash
#
# update alminium
#

ALM_SRC_DIR=${ALM_HOME}/alminium
ALM_INSTALL_DIR=/opt/alminium
ALM_SUBDIR=${ALM_RELATIVE_URL_ROOT}

# 関数群
source ${ALM_SRC_DIR}/inst-script/functions

# start updating
echo update ALMinium ...

#
# log
#
mkdir -p /var/log/alminium
mkdir -p /var/log/alminium/redmine
mkdir -p /var/log/alminium/apache2
chown -R www-data:www-data /var/log/alminium/redmine
chown -R root:adm /var/log/alminium/apache2
chmod 760 /var/log/alminium/*

#
# ALMinium's DB data
#

if [ ! -f ${ALM_HOME}/initialized ]; then
  # 未初期化状態なので初期化を行う
  while [ "`db_test`" = "" ]; do
    echo "checking db connection..."
    sleep 3
  done
  echo "successed to connect db."

  # gem install for redmine_jenkins and db migration
  source ${ALM_SRC_DIR}/redmine/setup/setup-db
  pushd ${ALM_INSTALL_DIR}
  mv plugins-jenkins/* plugins/
  bundle install --path vendor/bundle \
                 --without development test postgresql sqlite xapian
  bundle exec rake redmine:plugins:migrate \
         RAILS_ENV=production NAME=redmine_jenkins
  popd
  touch ${ALM_HOME}/initialized
fi

#
# attachement files
#
if [ ! -f /opt/alminium/files/initialized ]; then
  cd /opt/alminium && tar xzf ${ALM_HOME}/files.tar.gz
fi

#
# ALMinium's repo
#
if [ ! -f /var/opt/alminium/initialized ]; then
  cd /var/opt && tar xzf ${ALM_HOME}/repo.tar.gz
fi

# HOSTNAME
ALM_OLD_HOSTNAME=`cat /etc/opt/alminium/hostname`
if [ "${ALM_OLD_HOSTNAME}" != "${ALM_HOSTNAME}" ]; then
  echo "changed hostname: [${ALM_OLD_HOSTNAME}] -> [${ALM_HOSTNAME}]"
  cd /etc/opt/alminium
  for FILE in $(ls redmine*.conf)
  do
    sed -i.old "s|ServerName ${ALM_OLD_HOSTNAME}|ServerName ${ALM_HOSTNAME}|" \
        $FILE
  done
  echo ${ALM_HOSTNAME} > /etc/opt/alminium/hostname
fi

#
# RELATIVE_PATH
#
ALM_OLD_REL_PATH=`cat /etc/opt/alminium/relative_path`
if [ "`echo ${ALM_RELATIVE_URL_ROOT} | cut -c 1`" = "/" ]
then
  ALM_NEW_REL_PATH=`echo ${ALM_RELATIVE_URL_ROOT} | cut -c 2-`
else
  ALM_NEW_REL_PATH=${ALM_RELATIVE_URL_ROOT}
fi
# set old path and new path
if [ "${ALM_OLD_REL_PATH}" != "${ALM_NEW_REL_PATH}" ]
then
  echo "changed relative path: [${ALM_OLD_REL_PATH}] -> [${ALM_NEW_REL_PATH}]"
  if [ "${ALM_OLD_REL_PATH}" = "" ]
  then
    # case that non-rerative to rerative, 
    # ex.: http://localhost/projects/test 
    #  ==> http://localhost/alminium/projects/test
    OLD_PATH=
    NEW_PATH="/${ALM_NEW_REL_PATH}"
    REPLACE_FROM="DocumentRoot /opt/alminium/public"
    REPLACE_TO="DocumentRoot /var/www/html\nRailsBaseURI ${NEW_PATH}"
    ln -s /opt/alminium/public /var/www/html/${ALM_NEW_REL_PATH}
  elif [ "${ALM_NEW_REL_PATH}" = "" ]
  then
    # case that rerative to non-rerative,
    # ex.: http://localhost/alminium/projects/test
    #  ==> http://localhost/projects/test
    OLD_PATH="/${ALM_OLD_REL_PATH}"
    NEW_PATH=
    REPLACE_FROM="DocumentRoot /var/www/html\nRailsBaseURI ${OLD_PATH}"
    REPLACE_TO="DocumentRoot /opt/alminium/public"
    rm /var/www/html/${ALM_OLD_REL_PATH}
  else
    # case that rerative to different rerative,
    # ex.: http://localhost/alminium/projects/test
    #  ==> http://localhost/redmine/projects/test
    OLD_PATH="/${ALM_OLD_REL_PATH}"
    NEW_PATH="/${ALM_NEW_REL_PATH}"
    REPLACE_FROM="RailsBaseURI ${OLD_PATH}"
    REPLACE_TO="RailsBaseURI ${NEW_PATH}"
    mv /var/www/html/${ALM_OLD_REL_PATH} /var/www/html/${ALM_NEW_REL_PATH}
  fi

  # modify apache configuration
  cd /etc/opt/alminium
  for FILE in $(ls redmine*.conf vcs.conf)
  do
    sed -i.old \
        -e "s|${REPLACE_FROM}|${REPLACE_TO}|" \
        -e "s|Location ${OLD_PATH}/|Location ${NEW_PATH}/|" \
        -e "s|ScriptAlias ${OLD_PATH}/git|ScriptAlias ${NEW_PATH}/git|" \
        -e "s|WSGIScriptAlias ${OLD_PATH}/git|WSGIScriptAlias ${NEW_PATH}/git|" \
        ${FILE}
  done
  # modify hook command
  sed -i "s|localhost${OLD_PATH}|localhost${NEW_PATH}|g" \
      /opt/alminium/bin/alm-sync-scm
  # modify current relative path
  echo ${ALM_NEW_REL_PATH} > /etc/opt/alminium/relative_path
fi

#
# email
#
if [ "${SMTP_ENABLED}" = "true" ]
then
  cd /opt/alminium/config/
  echo "production:" > configuration.yml
  echo "  email_delivery:" >> configuration.yml
  echo "    delivery_method: :smtp" >> configuration.yml
  echo "    smtp_settings:" >> configuration.yml
  echo "      enable_starttls_auto: ${SMTP_ENALBLE_STARTTLS_AUTO}" >> configuration.yml
  echo "      address: ${SMTP_ADDRESS}" >> configuration.yml
  echo "      port: ${SMTP_PORT}" >> configuration.yml
  echo "      domain: ${SMTP_DOMAIN}" >> configuration.yml
  echo "      authentication: ${SMTP_AUTHENTICATION}" >> configuration.yml
  echo "      user_name: ${SMTP_USER_NAME}" >> configuration.yml
  echo "      password: ${SMTP_PASS}" >> configuration.yml
  chown www-data:www-data configuration.yml
elif [ -f /opt/alminium/config/configuration.yml ]
then  # remove old settings
  rm -f /opt/alminium/config/configuration.yml
fi

#
# config backup
#
if [ "${ALM_ENABLE_AUTO_BACKUP}" = "y" ]; then
  /opt/alminium/config-backup
else # no auto-backp
  rm -f /etc/cron.d/alminium-backup-cron
fi

#
# config ssl
#
if [ "`grep "#SSL#" /etc/opt/alminium/alminium.conf`" = "" ]; then
  ALM_ENABLE_SSL_OLD=y
else
  ALM_ENABLE_SSL_OLD=N
fi
if [ "${ALM_ENABLE_SSL_OLD}" != "${ALM_ENABLE_SSL}" ]; then
  cp -p /etc/opt/alminium/alminium.conf /etc/opt/alminium/alminium.conf.old
  cp -p /etc/opt/alminium/redmine.conf /etc/opt/alminium/redmine.conf.old
  if [ "${ALM_ENABLE_SSL_OLD}" = "N" -a "${ALM_ENABLE_SSL}" = "y" ]; then
    sed -i.old "s|#SSL# *||" /etc/opt/alminium/alminium.conf
    sed -i.old "s|#SSL# *||" /etc/opt/alminium/redmine.conf
    a2enmod ssl
  elif [ "${ALM_ENABLE_SSL_OLD}" = "y" -a "${ALM_ENABLE_SSL}" = "N" ]; then
    sed -i.old "s|Include /etc/opt/alminium/redmine-ssl.conf|#SSL# Include /etc/opt/alminium/redmine-ssl.conf|" /etc/opt/alminium/alminium.conf 
    sed -i.old "s|Rewrite|#SSL# Rewrite|" /etc/opt/alminium/redmine.conf
    a2dismod ssl
  fi
fi

# hostname
if [ "${ALM_PORT}" = "" -o "${ALM_PORT}" = "80" -o "${ALM_PORT}" = "443" ]; then
  HOST_NAME="${ALM_HOSTNAME}${ALM_RELATIVE_URL_ROOT}"
else
  HOST_NAME="${ALM_HOSTNAME}:${ALM_PORT}${ALM_RELATIVE_URL_ROOT}"
fi
db_update_setting host_name ${HOST_NAME}

# protocol
if [ "${ALM_ENABLE_SSL}" = "y" ]; then
  db_update_setting protocol https
else
  db_update_setting protocol http
fi

# go to HOMEDIR
cd ${ALM_HOME}

service apache2 restart

