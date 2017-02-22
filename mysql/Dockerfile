# docker image
FROM mysql:5.7

#environments
ENV MYSQL_DATABASE=alminium \
    MYSQL_USER=alminium \
    MYSQL_PASSWORD=alminium

# maintainer information
MAINTAINER ayapapa ayapapajapan@yahoo.co.jp

# copy start.sh
COPY ./start.sh /home/mysql/start.sh

# working directory
WORKDIR /home/mysql

# deamon
ENTRYPOINT /home/mysql/start.sh
