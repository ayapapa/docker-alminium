# docker image
FROM ubuntu:latest

# maintainer information
MAINTAINER ayapapa ayapapajapan@yahoo.co.jp

# environment vars
ENV ALM_HOME="/home/alm"  \
    ALM_HOSTNAME="localhost" \
    ALM_ENABLE_SSL="N" \
    ALM_RELATIVE_URL_ROOT="" \
    ALM_ENABLE_JENKINS="N"

# upgrade
RUN apt-get update && apt-get dist-upgrade -y

# install git
RUN apt-get install -y git

# clone alminium
COPY ./install.sh ${ALM_HOME}/install.sh
RUN ${ALM_HOME}/install.sh

# install upervisor
RUN apt-get install -y supervisor

# Expose web & ssh
EXPOSE 80

# Define data volumes
VOLUME ["/opt/alminium/files", "/var/opt/alminium", "/var/lib/mysql"]

# supervisor config
COPY ./supervisord.conf /etc/supervisord.conf

# intialize script
COPY ./update.sh ${ALM_HOME}/update.sh

# execute
WORKDIR ${ALM_HOME}
CMD /usr/bin/supervisord -c /etc/supervisord.conf

