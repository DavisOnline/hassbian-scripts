#!/bin/bash

function mosquitto-show-short-info {
  echo "MQTT 服务器"
}

function mosquitto-show-long-info {
  echo "安装本地 MQTT 服务器"
}

function mosquitto-show-copyright-info {
  echo "Copyright(c) 2016 Dale Higgs <https://github.com/dale3h>."
  echo "修改：Landrash"
  echo "本地化：墨澜 <http://cxlwill.cn>"
}

function mosquitto-install-package {
if [ "$ACCEPT" == "true" ]; then
  mqtt_username=pi
  mqtt_password=raspberry
else
  echo
  echo "创建 MQTT 用户"
  echo

  echo -n "请输入用户名："
  read -r mqtt_username
  if [ ! "$mqtt_username" ]; then
    mqtt_username=pi
  fi

  echo -n "请输入密码："
  read -s -r mqtt_password
  echo
  if [ ! "$mqtt_password" ]; then
    mqtt_password=raspberry
  fi
fi

echo "添加 mosquitto 用户"
adduser mosquitto --system --group

echo "创建 pid 文件"
touch /var/run/mosquitto.pid
chown mosquitto:mosquitto /var/run/mosquitto.pid

echo "创建数据文件"
mkdir -p /var/lib/mosquitto
chown mosquitto:mosquitto /var/lib/mosquitto

echo "安装软件源秘钥"
wget -O - http://repo.mosquitto.org/debian/mosquitto-repo.gpg.key | apt-key add -

echo "添加软件源"
OS_VERSION=$(lsb_release -cs)
if [ ! -f /etc/apt/sources.list.d/mosquitto-"$OS_VERSION".list ]
then
  sudo curl -o /etc/apt/sources.list.d/mosquitto-"$OS_VERSION".list http://repo.mosquitto.org/debian/mosquitto-"$OS_VERSION".list
else
  echo "已添加，跳过..."
fi


echo "安装 mosquitto"
apt-get update
apt-cache search mosquitto
apt-get install -y mosquitto mosquitto-clients

echo "写入默认配置"
cd /etc/mosquitto || exit
mv mosquitto.conf mosquitto.conf.backup
cp /opt/hassbian/suites/files/mosquitto.conf /etc/mosquitto/mosquitto.conf
chown mosquitto:mosquitto mosquitto.conf

echo "密码文件初始化"
touch pwfile
chown mosquitto:mosquitto pwfile
chmod 0600 pwfile

echo "为用户 $mqtt_username 添加密码"
mosquitto_passwd -b pwfile "$mqtt_username" "$mqtt_password"

echo "重启 Mosquitto 服务"
systemctl restart mosquitto.service

ip_address=$(ifconfig | grep "inet.*broadcast" | grep -v 0.0.0.0 | awk '{print $2}')

echo "安装检查..."
validation=$(pgrep -f mosquitto)
if [ ! -z "${validation}" ]; then
  echo
  echo -e "\\e[32m安装成功\\e[0m"
  echo
  echo "MQTT 服务器运行在 $ip_address:1883"
  echo ""
  echo "欢迎阅读相关英文文档：https://home-assistant.io/docs/mqtt/"
  echo "欢迎阅读相关中文文档：https://home-assistant.cc/component/mqtt/"
  echo
else
  echo
  echo -e "\\e[31m安装失败..."
  echo -e "\\e[31m中止..."
  echo -e "\\e[0m对此脚本有任何疑问或建议, 欢迎加QQ群515348788讨论"
  echo -e "\\e[0mHome Assistant入门视频教程：http://t.cn/RQPeEQv"
  echo
  return 1
fi
return 0
}

[[ "$_" == "$0" ]] && echo "hassbian-config helper script; do not run directly, use hassbian-config instead"
