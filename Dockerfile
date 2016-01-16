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

# for mysql auto installation
ENV DEBIAN_FRONTEND=noninteractive

# upgrade
RUN apt-get update && apt-get dist-upgrade -y

# install git
RUN apt-get install -y git

# clone alminium
COPY ./install.sh ${ALM_HOME}/install.sh
RUN ${ALM_HOME}/install.sh
#RUN git clone -b docker-dev https://github.com/ayapapa/alminium.git ${ALM_HOME}/alminium
#RUN cd ${ALM_HOME}/alminium && sudo -E ./smelt

# install upervisor
RUN apt-get install -y supervisor

# supervisor config
COPY ./supervisord.conf /etc/supervisord.conf

# intialize script
COPY ./update.sh ${ALM_HOME}/update.sh

# command
CMD /usr/bin/supervisord -c /etc/supervisord.conf

