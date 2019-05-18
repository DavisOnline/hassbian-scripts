#!/bin/bash
function hassbian-show-short-info {
  echo "Hassbian 系统"
}

function hassbian-show-long-info {
  echo "更新 Hassbian 系统"
}

function hassbian-show-copyright-info {
  echo "智能家居控制中心"
  echo "Copyright(c) 2019 Davis Pan <E-mail：Davis.Pan@outlook.com>"
}

function hassbian-upgrade-package {
hassbian-show-short-info
hassbian-show-copyright-info

echo "更新软件表"
sudo apt update

echo "更新系统"
sudo apt upgrade -y

echo
echo "更新完成"
echo
echo "部分更新重启后才能生效"
echo
return 0
}

[[ "$_" == "$0" ]] && echo "hassbian-config helper script; do not run directly, use hassbian-config instead"
