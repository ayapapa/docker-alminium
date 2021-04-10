#!/bin/bash

# 環境変数
JENKINS_HOME_DIR=/var/lib/jenkins
JENKINS_PLUGIN_DIR=${JENKINS_HOME_DIR}/plugins

# 関数
# /var/lib/jenkins/config.xmlを編集して、セキュリティを解除する
unlock_security() {
  echo "セキュリティ解除(/var/lib/jenkins/config.xmlを編集)"
  # 初期化中で、config.xmlが未作成となっていることがあるため、待つ
  while [ ! -f /var/lib/jenkins/config.xml ]
  do
    echo /var/lib/jenkins/config.xmlが見つからないため、作成されるまで待つ
    sleep 5
  done
  echo /var/lib/jenkins/config.xmlを発見したので、初期化を継続する
  # 念のため待つ
  sleep 10
  echo "セキュリティ解除(/var/lib/jenkins/config.xmlを編集)"
  #sed -i.org "s/<useSecurity>true/<useSecurity>false/" ${JENKINS_HOME_DIR}/config.xml
  sed -i.org \
      -e "s/<authorizationStrategy class=\"hudson.security.FullControlOnceLoggedInAuthorizationStrategy\">/<authorizationStrategy class=\"hudson.security.AuthorizationStrategy\$Unsecured\"\/>\n  <\!-- <authorizationStrategy class=\"hudson.security.FullControlOnceLoggedInAuthorizationStrategy\"> -->/" \
      -e "s/<denyAnonymousReadAccess/<\!-- <denyAnonymousReadAccess/" \
      -e "s/\/denyAnonymousReadAccess>/\/denyAnonymousReadAccess> -->/" \
      -e "s/<\/authorizationStrategy>/<\!-- <\/authorizationStrategy> -->/" \
      /var/lib/jenkins/config.xml
}

# Jenkinsの立ち上がりを待つ
wait_for_jenkins_up() {
  # try connect to jenkins service up
  local RET=-1
  until  [ "$RET" -eq "0" ]
  do
    echo "Jenkinsが立ち上がるまで待ちます..."
    sleep 10
    curl localhost:8080/jenkins 2>/dev/null
    RET=$?
  done
  echo "Jenkinsが立ち上がりました！"
  # 念のため
  sleep 10
}

# Jenkinsを再起動する。
restart_jenkins() {
  echo Jenkins再起動
  service jenkins restart
  wait_for_jenkins_up
}

# Jenkins起動
service jenkins start
#wailするとエラーが起こり、その先に進めなくなるので、コメントアウト
#wait_for_jenkins_up

# 初期化済ならこのまま待機
if [ -f /var/jenkins.flags/jenkins.initialized ]; then
  echo 初期化済みのため、このまま待機します
  sleep infinity
fi

echo 初期化を開始します...

echo 念のため所有権を設定
chown -R jenkins:jenkins ${JENKINS_HOME_DIR}/

echo Jenkins起動フラグ変更
sed -i 's/JENKINS_ARGS="--webroot/JENKINS_ARGS="--prefix=\/jenkins --webroot/' /etc/default/jenkins

# create jenkins plugin directry
if [ ! -d ${JENKINS_PLUGIN_DIR} ]; then
  mkdir -p ${JENKINS_PLUGIN_DIR}
  chown jenkins:jenkins ${JENKINS_PLUGIN_DIR}
fi

# "セキュリティ解除"
unlock_security

# Jenkins再起動
restart_jenkins

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

  echo "プラグインManagerにプロキシー設定を指示する"
  RET=-1
  while [ "$RET" -ne "0" ]
  do
    curl --noproxy localhost -X POST \
    --data "json={\"name\": \"$proxyserver\", \"port\": \"$proxyport\", \"userName\": \"$proxyuser\", \"password\": \"$proxypass\", \"noProxyHost\": \"\"}" \
    http://localhost:8080/jenkins/pluginManager/proxyConfigure --verbose
    RET=$?
    if [ "$RET" -ne "0" ]; then
      echo "proxy setting for jenkins fail. retrying..."
      echo "Jenkinsのセキュリティ解除が失敗している可能性があるため、再度セキュリティ解除を試みる"
      unlock_security
      echo "セキュリティ解除を行ったので、Jenkinsを再起動する"
      restart_jenkins
    fi
  done
  restart_jenkins
fi

echo "プラグインインストール"
sleep 10
mkdir -p tmp
pushd tmp

install_jenkins_plugins() {
  local plugin_name=${1}
  if [ ! -d ${JENKINS_PLUGIN_DIR}/${plugin_name} ]; then
    local result=-1
    until  [ "${result}" -eq "0" ]; do
      java -jar ${JENKINS_HOME_DIR}/jenkins-cli.jar \
           -s http://localhost:8080/jenkins/ install-plugin ${plugin_name}
      result=$?
      if [ "${result}" != "0" ]; then
        echo "### プラグインインストール中にエラーが発生しました。"
        echo "### セキュリティ解除に失敗している可能性があるため、再度セキュリティ解除を行った後、"
        echo "### プラグインのインストールを試みます。"
        unlock_security
        restart_jenkins
        sleep 10
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
  echo "Jenkinsの再起動に失敗しました。ログ等を確認し対処してください"
  exit 1
fi

# 初期化済フラグを立てる
if [ ! -d /var/jenkins.flags ]; then
  mkdir /var/jenkins.flags
fi
echo "initialized!" > /var/jenkins.flags/jenkins.initialized

echo "☆Jenkins初期化が完了しました☆"

# keep running this docker
sleep infinity
