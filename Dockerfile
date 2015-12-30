# docker image
FROM ayapapa/docker-alminium:0.3

# maintainer information
MAINTAINER ayapapa ayapapajapan@yahoo.co.jp

# install upervisor
RUN apt-get update && apt-get install -y supervisor

# supervisor設定
RUN touch /etc/supervisord.conf \
&& echo '[supervisord]'  >> /etc/supervisord.conf \
&& echo 'nodaemon=true'  >> /etc/supervisord.conf \
&& echo '[rpcinterface:supervisor]'  >> /etc/supervisord.conf \
&& echo 'supervisor.rpcinterface_factory = supervisor.rpcinterface:make_main_rpcinterface'  >> /etc/supervisord.conf \
&& echo '[supervisorctl]'  >> /etc/supervisord.conf \
&& echo '[program:init]'  >> /etc/supervisord.conf \
&& echo 'command=/home/init.sh'  >> /etc/supervisord.conf \
&& echo '[program:mysql]'  >> /etc/supervisord.conf \
&& echo 'startretries=10' \
&& echo 'command=service mysql start'  >> /etc/supervisord.conf \
&& echo '[program:apache2]'  >> /etc/supervisord.conf \
&& echo 'startretries=10' \
&& echo 'command=service apache2 start'  >> /etc/supervisord.conf

COPY ./init.sh /home/init.sh

CMD /usr/bin/supervisord -c /etc/supervisord.conf

