#!/bin/bash

function mssql-show-short-info {
  echo "MS SQL 数据库"
}

function mssql-show-long-info {
  echo "安装 MS SQL 数据库"
}

function mssql-show-copyright-info {
  echo "智能家居控制中心"
  echo "Copyright(c) 2019 Davis Pan <E-mail：Davis.Pan@outlook.com>"
}

function mssql-install-package {
mssql-show-short-info
mssql-show-copyright-info

echo "安装数据库软件"
apt-get update
apt-get install -y freetds-dev


echo "切换至 homeassistant 用户"
sudo -u homeassistant -H /bin/bash <<EOF

echo "进入 Home Assistant 虚拟环境"
source /srv/homeassistant/bin/activate

echo "安装 MS SQL 依赖"
pip3 install --upgrade setuptools wheel -i https://mirrors.aliyun.com/pypi/simple/
pip3 install pymssql -i https://mirrors.aliyun.com/pypi/simple/

echo "退出虚拟环境"
deactivate
EOF

echo "安装检查..."
validation=$(sudo -u homeassistant -H /bin/bash << EOF | grep Version | awk '{print $2}'
source /srv/homeassistant/bin/activate
pip3 show pymssql
EOF
)
if [ ! -z "${validation}" ]; then
  echo
  echo -e "\\e[32m安装完成..\\e[0m"
  echo
  echo "请注意此脚本不会创建任何数据库或者用户，请之后进行手动创建！"
  echo
else
  echo
  echo -e "\\e[31m安装失败..."
  echo -e "\\e[31m退出..."
  echo
  return 1
fi
return 0
}

[[ "$_" == "$0" ]] && echo "hassbian-config helper script; do not run directly, use hassbian-config instead"
