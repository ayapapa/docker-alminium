# docker image
FROM mysql:5.7

#environments
ENV MYSQL_DATABASE=alminium \
    MYSQL_USER=alminium \
    MYSQL_PASSWORD=alminium

# maintainer information
MAINTAINER ayapapa ayapapajapan@yahoo.co.jp

RUN { \
    echo '[mysqld]'; \
    echo 'character-set-server=utf8'; \
    echo 'collation-server=utf8_general_ci'; \
    echo '[client]'; \
    echo 'default-character-set=utf8'; \
} > /etc/mysql/conf.d/charset.cnf

# copy start.sh
COPY ./start.sh /home/mysql/start.sh

# working directory
WORKDIR /home/mysql

# deamon
ENTRYPOINT /home/mysql/start.sh

# command
#CMD /bin/bash
