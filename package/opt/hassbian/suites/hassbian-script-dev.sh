#!/bin/bash
function hassbian-script-dev-show-short-info {
  echo "Hassbian-Script 开发版"
}

function hassbian-script-dev-show-long-info {
  echo "此脚本将下载并安装 Github 中 Hassbian-Script 的最新开发版"
  echo "从而帮助你进行相关开发"
  echo "此脚本不适用于生产环境"
}

function hassbian-script-dev-show-copyright-info {
	echo "原创：Ludeeus <https://github.com/Ludeeus>"
  echo "本地化：墨澜 <http://cxlwill.cn>"
}

function hassbian-script-dev-upgrade-package {
hassbian-script-dev-show-short-info
hassbian-script-dev-show-copyright-info

echo "切换至临时文件夹"
cd || exit
sudo mkdir /tmp/hassbian_config_update
cd /tmp/hassbian_config_update || exit

echo "下载最新版本脚本"
curl -L https://api.github.com/repos/home-assistant/hassbian-scripts/tarball| sudo tar xz --strip=1

echo "复制文件"
yes | sudo cp -rf /tmp/hassbian_config_update/package/usr/local/bin/hassbian-config /usr/local/bin/hassbian-config
yes | sudo cp -rf /tmp/hassbian_config_update/package/opt/hassbian/suites/* /opt/hassbian/suites/

echo "移除临时文件夹"
cd || exit
sudo rm -r /tmp/hassbian_config_update

echo
echo "更新完成"
echo
return 0
}

[[ "$_" == "$0" ]] && echo "hassbian-config helper script; do not run directly, use hassbian-config instead"
