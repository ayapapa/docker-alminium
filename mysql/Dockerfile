# docker image
FROM mysql:5.7

# maintainer information
MAINTAINER ayapapa ayapapajapan@yahoo.co.jp

#environments(don't edit)
ENV MYSQL_ROOT_PASSWORD= \
    MYSQL_ALLOW_EMPTY_PASSWORD=yes \
    MYSQL_DATABASE=alminium \
    MYSQL_USER=alminium \
    MYSQL_PASSWORD=alminium

# set default charset to utf8
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

