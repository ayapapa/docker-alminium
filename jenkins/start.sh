#!/bin/bash

# 環境変数
JENKINS_HOME_DIR=/var/lib/jenkins
JENKINS_PLUGIN_DIR=${JENKINS_HOME_DIR}/plugins

# Jenkins起動
service jenkins start

# 初期化済ならこのまま待機
if [ -f /var/jenkins.flags/jenkins.initialized ]; then
  echo 初期化済み
  sleep infinity
fi

echo 初期化を開始します...

echo 念のため所有権を設定
chown -R jenkins:jenkins ${JENKINS_HOME_DIR}/

echo Jenkinsを一旦停止
service jenkins stop

echo Jenkins起動フラグ変更
sed -i 's/JENKINS_ARGS="--webroot/JENKINS_ARGS="--prefix=\/jenkins --webroot/' /etc/default/jenkins

# create jenkins plugin directry
if [ ! -d ${JENKINS_PLUGIN_DIR} ]; then
  mkdir -p ${JENKINS_PLUGIN_DIR}
  chown jenkins:jenkins ${JENKINS_PLUGIN_DIR}
fi

echo セキュリティ解除後に、Jenkins起動
sed -i.org "s/<useSecurity>true/<useSecurity>false/" ${JENKINS_HOME_DIR}/config.xml
service jenkins start

# try connect to jenkins service up
curl localhost:8080/jenkins 2>/dev/null

# download jenkins-cli.jar
RET=-1
until  [ "$RET" -eq "0" ]
do
  echo "Jenkinsへの接続を試みます..."
  sleep 10
  wget --no-proxy -O ${JENKINS_HOME_DIR}/jenkins-cli.jar http://localhost:8080/jenkins/jnlpJars/jenkins-cli.jar 2>/dev/null
  RET=$?
done

wget -O /tmp/default.js http://updates.jenkins-ci.org/update-center.json

# remove first and last line javascript wrapper
sed '1d;$d' /tmp/default.js > /tmp/default.json

# Now push it to the update URL
if [ ! -e ${JENKINS_HOME_DIR}/updates ]; then
  mkdir -p ${JENKINS_HOME_DIR}/updates
fi
cp -f /tmp/default.json ${JENKINS_HOME_DIR}/updates/

# Jenkinsのプロキシ設定
if [ x"$http_proxy" != x"" ]; then
  # set proxy. sorry IPv4 only and user:pass not supported...
  proxyuser=`echo $http_proxy | sed -n 's/.*:\/\/\([a-zA-Z0-9]*\):.*/\1/p'`
  proxypass=`echo $http_proxy | sed -n 's/.*:\/\/[a-zA-Z0-9]*:\([a-zA-Z0-9:]*\)\@.*/\1/p'`
  echo
  echo proxyuser=$proxyuser
  echo proxypass=$proxypass

  if [ x"$proxyuser" != x"" ]; then
    http_proxy=`echo $http_proxy | sed "s/$proxyuser:$proxypass\@//"`
  fi

  proxyserver=`echo $http_proxy | cut -d':' -f2 | sed 's/\/\///g'`
  proxyport=`echo $http_proxy | cut -d':' -f3 | sed 's/\///g'`
  echo proxyserver=$proxyserver
  echo proxyport=$proxyport

  curl --noproxy localhost -X POST \
    --data "json={\"name\": \"$proxyserver\", \"port\": \"$proxyport\", \"userName\": \"$proxyuser\", \"password\": \"$proxypass\", \"noProxyHost\": \"\"}" \
    http://localhost:8080/jenkins/pluginManager/proxyConfigure --verbose
  RET=$?
  if [ "$RET" -ne "0" ]; then
    echo "proxy setting for jenkins fail"
    exit 1
  fi
  service jenkins restart
fi

echo プラグインインスト―ル
sleep 10
mkdir -p tmp
pushd tmp

install_jenkins_plugins() {
  local plugin_name=${1}
  if [ ! -d ${JENKINS_PLUGIN_DIR}/${plugin_name} ]; then
    local resalt=-1
    until  [ "${resalt}" -eq "0" ]; do
      sleep 3
      java -jar ${JENKINS_HOME_DIR}/jenkins-cli.jar \
           -s http://localhost:8080/jenkins/ install-plugin ${plugin_name}
      resalt=$?
      if [ "${resalt}" != "0" ]; then
        echo "### プラグインインストール中にエラーが発生しました。"
        echo "### 再度、プラグインのインストールを試みます。"
      fi
    done
  fi
}

install_jenkins_plugins reverse-proxy-auth-plugin
#install_jenkins_plugins persona
install_jenkins_plugins git
install_jenkins_plugins redmine
install_jenkins_plugins dashboard-view

popd
rm -rf tmp
# persona-hudmi取得
if [ ! -d ${JENKINS_HOME_DIR}/persona ]; then
  git clone https://github.com/okamototk/jenkins-persona-hudmi ${JENKINS_HOME_DIR}/persona
fi

# Jenkins再起動
java -jar ${JENKINS_HOME_DIR}/jenkins-cli.jar -s http://localhost:8080/jenkins/ restart

# エラーチェック
RET=$?
if [ "$RET" -ne "0" ]; then
  echo "proxy setting for jenkins fail"
  exit 1
fi

# 初期化済フラグを立てる
if [ ! -d /var/jenkins.flags ]; then
  mkdir /var/jenkins.flags
fi
echo "initialized!" > /var/jenkins.flags/jenkins.initialized

# keep running this docker
sleep infinity
