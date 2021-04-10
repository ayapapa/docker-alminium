# docker image
FROM ubuntu:20.04

# maintainer information
MAINTAINER ayapapa ayapapajapan@yahoo.co.jp

#env
ENV JENKINS_HOME=/var/lib/jenkins

# install packes and setup jenkins
RUN \
  apt-get update && \
  apt-get install -y curl git openjdk-8-jre-headless \
                     wget gnupg gnupg1 gnupg2 && \
  wget -q -O - https://pkg.jenkins.io/redhat/jenkins.io.key | apt-key add - && \
  echo "deb https://pkg.jenkins.io/debian binary/" \
    > /etc/apt/sources.list.d/jenkins.list && \
  apt-get update && \
  apt-get dist-upgrade -y && \
  apt-get -y install jenkins

#expose port
EXPOSE 8080

# Define data volumes
VOLUME ["${JENKINS_HOME}"]

# working directory
WORKDIR ${JENKINS_HOME}

#copy start.sh
COPY ./start.sh  ${JENKINS_HOME}/start.sh

# run as root
USER root

# deamon
ENTRYPOINT ${JENKINS_HOME}/start.sh

# command
CMD /bin/bash
