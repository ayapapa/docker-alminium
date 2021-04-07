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

# copy scripts
COPY ./*.sh /home/mysql/

# set default charset to utf8
RUN { \
      echo '[mysqld]'; \
      echo 'character-set-server=utf8'; \
      echo 'collation-server=utf8_general_ci'; \
      echo '[client]'; \
      echo 'default-character-set=utf8'; \
    } > /etc/mysql/conf.d/charset.cnf && \
    { \
      echo '[mysqld]'; \
      echo 'explicit_defaults_for_timestamp = true'; \
    } >> /etc/mysql/my.cnf #&& \
#    /home/mysql/initialize.sh

# working directory
WORKDIR /home/mysql

# deamon
ENTRYPOINT /home/mysql/start.sh

