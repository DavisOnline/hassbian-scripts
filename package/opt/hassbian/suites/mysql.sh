#!/bin/bash

function mysql-show-short-info {
  echo "MySQL 安装脚本"
}

function mysql-show-long-info {
  echo "安装 MySQL 数据库"
}

function mysql-show-copyright-info {
  echo "Copyright(c) 2017 Fredrik Lindqvist <https://github.com/Landrash>."
  echo "本地化：墨澜 <http://cxlwill.cn>"
}

function mysql-install-package {
mysql-show-short-info
mysql-show-copyright-info

echo "安装数据库软件"
apt-get update
apt-get install -y default-libmysqlclient-dev libssl-dev

echo "切换至 homeassistant 用户"
sudo -u homeassistant -H /bin/bash <<EOF

echo "进入 Home Assistant 虚拟环境"
source /srv/homeassistant/bin/activate

echo "安装 MySQL 依赖"
pip3 install mysqlclient -i https://mirrors.aliyun.com/pypi/simple/

echo "退出虚拟环境"
deactivate
EOF

echo "安装检查..."
validation=$(sudo -u homeassistant -H /bin/bash << EOF | grep Version | awk '{print $2}'
source /srv/homeassistant/bin/activate
pip3 show mysqlclient
EOF
)
if [ ! -z "${validation}" ]; then
  echo
  echo -e "\\e[32m安装完成..\\e[0m"
  echo
  echo "请注意此脚本不会创建任何数据库或者用户，请之后进行手动创建！"
  echo
  echo "欢迎阅读相关英文文档：https://home-assistant.io/components/recorder/"
  echo "欢迎阅读 HA 中文文档：https://home-assistant.cc"
  echo -e "\\e[0m对此脚本有任何疑问或建议, 欢迎加QQ群515348788讨论"
  echo
else
  echo
  echo -e "\\e[31m安装失败..."
  echo -e "\\e[31m退出..."
  echo -e "\\e[0m对此脚本有任何疑问或建议, 欢迎加QQ群515348788讨论"
  echo -e "\\e[0mHome Assistant入门视频教程：http://t.cn/RQPeEQv"
  echo
  return 1
fi
return 0
}

[[ "$_" == "$0" ]] && echo "hassbian-config helper script; do not run directly, use hassbian-config instead"
