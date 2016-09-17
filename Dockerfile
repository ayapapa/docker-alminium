# docker image
FROM ubuntu:16.04

# maintainer information
MAINTAINER ayapapa ayapapajapan@yahoo.co.jp

# environment vars
ENV ALM_HOME="/home/alm"  \
    ALM_HOSTNAME="localhost" \
    ALM_ENABLE_SSL="N" \
    ALM_RELATIVE_URL_ROOT="" \
    ALM_ENABLE_JENKINS="N" \
    ALM_ENABLE_AUTO_BACKUP="y" \
    ALM_BACKUP_MINUTE="0" \
    ALM_BACKUP_HOUR="3" \
    ALM_BACKUP_DAY="*/2" \
    ALM_BACKUP_EXPIRY="14" \
    ALM_BACKUP_DIR="/var/opt/alminium-backup" \
    ALM_BACKUP_LOG="/opt/alminium/log/backup.log" \
    ALM_VER="v3.3.0a" \
    RM_VER=3.3.0 \
    DEBIAN_FRONTEND=noninteractive
    
  # auto backup in every 2 days at 3 A.M.

# upgrade
RUN apt-get update && apt-get dist-upgrade -y

# install git
RUN apt-get install -y apache2 bc g++ git \
    imagemagick libapache2-mod-passenger libapache2-mod-perl2 \
    libapache2-mod-wsgi libapache2-svn libdbd-mysql-perl \
    libdbi-perl libmagickcore-dev libmagickwand-dev \
    libmysqlclient-dev libsqlite3-dev libssl-dev make \
    mercurial mysql-server php-mysql ruby ruby-dev subversion \
    unzip wget

# clone alminium
COPY ./install.sh ${ALM_HOME}/install.sh
RUN ${ALM_HOME}/install.sh

# install upervisor
RUN apt-get install -y supervisor

# Expose web
EXPOSE 80 443

# Define data volumes
VOLUME ["/opt/alminium/files", "/var/opt/alminium", "/var/lib/mysql"]

# supervisor config
COPY ./supervisord.conf /etc/supervisord.conf

# intialize script
COPY ./update.sh ${ALM_HOME}/update.sh

# working directory
WORKDIR ${ALM_HOME}

# deamon
ENTRYPOINT /usr/bin/supervisord -c /etc/supervisord.conf

# command
CMD /bin/bash

