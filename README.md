# What?
This is ALMinium's docker version without Jenkins.  
ALMiniumのDocker版を作ってみるサイトです。 今のところ、Jenkinsのインストールは無効としています。  
docker-composeを利用していますので、docker-compose.ymlのポート番号や環境変数を変更することでカスタマイズ出来ます。起動は、"docker-compose up -d"と叩くだけです。  
refs:  
* ALMinium: https://github.com/ayapapa/alminium, which is forked from https://github.com/alminium/alminium  
* Docker image: https://hub.docker.com/r/ayapapa/docker-alminium/  

# Prerequisites
## install docker
see https://docs.docker.com/engine/installation/   
In case of installation on Ubuntu 14.04(LTS):  
```shell
sudo apt-get update
sudo apt-get install docker.io
sudo sh -c "echo deb https://get.docker.com/ubuntu docker main > /etc/apt/sources.list.d/docker.list"
sudo apt-get update
sudo apt-get install lxc-docker
```

## install docker-compose
see https://docs.docker.com/compose/  
for example:
```shell
sudo su
[sudo] password for user-name: (your password)
curl -L https://github.com/docker/compose/releases/download/1.5.2/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
```

# How to start  
```shell
git clone https://github.com/ayapapa/docker-alminium.git  
cd docker-alminium  
sudo docker-compose up -d  
```
You can use AMinium(Redmine + several plugins) trough web-browser with URL http://localhost:10080.  
ブラウザで http://localhost:10080 をアクセスするとALMiniumが表示されます。  
And you can change the port number(default is 10080) by editing docker-composer.yml and restarting.  
see https://docs.docker.com/compose/

# Environment Variables  
You can configure by modifying Envitonment Variables in docker-compose.yml.  

| name | description |
|:-----|:------------|
| ALM_HOSTNAME | The hostname of the ALMinium server. Defaults to localhost. |
| ALM_ENABLE_SSL | Enable SSL, y(es) or N(o). Defaults to N. |
| ALM_RELATIVE_URL_ROOT | The relative url of the ALMinium server. If set "alminium", you can access http://localhost:10080/alminium/. No default. |
| ALM_ENABLE_AUTO_BACKUP | Enable auto backup, y(es) or N(o). Defaults to y. | 
| ALM_BACKUP_MINUTE | Auto backup schedule, crontab minute section(0-59). Defaults to 0. |
| ALM_BACKUP_HOUR   | Auto backup schedule, crontab hour section(0-23). Defaults to 3. |
| ALM_BACKUP_DAY    | Auto backup schedule, crontab day section(0-31). Defaults to */2. |
| ALM_BACKUP_EXPIRY | Auto backup schedule, how long (in days) to keep backups before they are deleted. Defaults to 14. |
| SMTP_ENABLED | Enable smtp mail delivery, true or false. Defaults to false. |
| SMTP_ENALBLE_STARTTLS_AUTO | Enable STARTTLS, true or false. Defaults to true. |
| SMTP_ADDRESS | SMTP server host address. Defaults to smtp.gmail.com |
| SMTP_PORT    | SMTP server port. Defaults to 587. |
| SMTP_DOMAIN  | SMTP domain. Defaults to smtp.gmail.com |
| SMTP_AUTHENTICATION | Specify the SMTP authentication method. Defaults to :login. |
| SMTP_USER_NAME | SMTP username. |
| SMTP_PASS      | SMTP password. |

