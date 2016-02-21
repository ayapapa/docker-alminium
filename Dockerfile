# docker image
#FROM ubuntu:14.04
FROM ayapapa/ubuntu1404:20160221

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
    ALM_VER="v3.2.0c"
  # auto backup in every 2 days at 3 A.M.

# upgrade
RUN apt-get update && apt-get dist-upgrade -y

# install git
RUN apt-get install -y git

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

# execute
WORKDIR ${ALM_HOME}

# deamon
ENTRYPOINT /usr/bin/supervisord -c /etc/supervisord.conf

# command
CMD /bin/bash

