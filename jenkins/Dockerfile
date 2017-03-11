# docker image
FROM jenkins:alpine

# maintainer information
MAINTAINER ayapapa ayapapajapan@yahoo.co.jp

# jenkins_home's permission
#RUN { \
#  if [ "$(grep chown /usr/local/bin/jenkins.sh)" = "" ]; then \
#    sed -i \
#        "s|^#! /bin/bash -e$|a chown -R jenkins:jenkins /var/jenkins_home|" \
#        /usr/local/bin/jenkins.sh; \
#  fi \
#}
USER root
#ENTRYPOINT ["/bin/tini", "--", "/start.sh"]
