# (UNDER CONSTRUCTION : 開発中)
# What?
This is ALMinium's docker version trial.  
ALMiniumのDocker版を作ってみるサイトです。うまくいったらご喝采。  
docker-composeを利用していますので、docker-compose.ymlのポート番号や環境変数を変更することでカスタマイズ出来ます。起動は、"docker-compose up -d"と叩くだけです。  
refs:  
ALMinium https://github.com/ayapapa/alminium, which is forked from https://github.com/alminium/alminium  
Docker-ALMinium https://hub.docker.com/r/ayapapa/docker-alminium/  

## Prerequisites
### install docker
see https://docs.docker.com/engine/installation/   
In case of installation on Ubuntu 14.04(LTS):  
```shell
sudo apt-get update
sudo apt-get install docker.io
sudo sh -c "echo deb https://get.docker.com/ubuntu docker main > /etc/apt/sources.list.d/docker.list"
sudo apt-get update
sudo apt-get install lxc-docker
```

### install docker-compose
see https://docs.docker.com/compose/
for example:
```shell
sudo su
[sudo] password for user-name: (your password)
curl -L https://github.com/docker/compose/releases/download/1.5.2/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
```

## How to start Docker-ALMinium
```shell
git clone https://github.com/ayapapa/docker-alminium.git  
cd docker-alminium  
sudo docker-compose up -d  
```
Note: unable to use relatrive url root and hostname, not yet.  
注意: まだホスト名指定とサブディレクトリ指定は利用できません。  
You can use AMinium(Redmine + sevral plugins) trough web-browser with URL http://localhost:10080.  
ブラウザでhttp://localhost:10080をアクセスするとALMiniumが表示されます。  
And you can change the port number(default = 10080) by editing docker-composer.yml and restarting.
