# What?
This is ALMinium(#)'s docker version trial.  
ALMiniumのDocker版を作ってみるサイトです。うまくいったらご喝采。  
(#)https://github.com/ayapapa/alminium, which is forked from https://github.com/alminium/alminium

## Prepare (準備)
### install docker
see https://docs.docker.com/engine/installation/

### install docker-compose
see https://docs.docker.com/compose/

## How to start ALMinium
$ git clone https://github.com/ayapapa/docker-alminium.git  
$ cd docker-alminium  
$ sudo docker-compose up -d  
Note: unable to use reratrive url root and hostname, not yet.  
注意: まだホスト名指定とサブディレクトリ指定は利用できません。  
You can access AMinium(Redmine+sevral pulugins) by http://localhost:10080.  
ブラウザでhttp://localhost:10080をアクセスするとALMiniumが表されます。
