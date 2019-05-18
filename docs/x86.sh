#!/bin/bash
function x86-show-short-info {
  echo "x86环境配置（使用root用户）"
}

function x86-show-long-info {
  echo "x86环境配置（使用root用户）"
}

function x86-show-copyright-info {
  echo "智能家居控制中心"
  echo "Copyright(c) 2019 Davis Pan <E-mail：Davis.Pan@outlook.com>"
}

function x86-install-package {

x86-show-short-info
x86-show-copyright-info

echo "创建homeassistant用户及用户组"
groupadd -f -r -g 1001 homeassistant
useradd -u 1001 -g 1001 -rm homeassistant

echo "创建homeassistant安装环境"
install -v -o 1001 -g 1001 -d /srv/homeassistant

echo "环境配置完成，你现在可以使用脚本安装其他软件"
}
