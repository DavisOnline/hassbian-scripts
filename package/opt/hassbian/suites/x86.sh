#!/bin/bash
function x86-show-short-info {
  echo "x86环境配置"
}

function x86-show-long-info {
  echo "x86环境配置"
}

function x86-show-copyright-info {
  echo "原创：墨澜 <http://cxlwill.cn>"
}

function x86-install-package {

x86-show-short-info
x86-show-copyright-info

echo "创建homeassistant用户及用户组"
on_chroot << EOF
groupadd -f -r -g 1001 homeassistant
useradd -u 1001 -g 1001 -rm homeassistant
EOF

echo "创建homeassistant安装环境"
install -v -o 1001 -g 1001 -d /srv/homeassistant

echo "环境配置完成，你现在可以使用脚本安装其他软件"
}
