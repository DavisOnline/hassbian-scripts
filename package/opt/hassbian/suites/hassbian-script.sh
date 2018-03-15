#!/bin/bash
function hassbian-script-show-short-info {
    echo "Hassbian-Script"
}

function hassbian-script-show-long-info {
    echo "更新 hassbian-scripts"
}

function hassbian-script-show-copyright-info {
    echo "原创：Ludeeus <https://github.com/ludeeus>"
    echo "本地化：墨澜 <http://cxlwill.cn>"
}

function hassbian-script-upgrade-package {
hassbian-script-show-short-info
hassbian-script-show-copyright-info

echo "切换至临时文件夹"
cd /tmp || exit

echo "下载最新版本脚本"
curl https://api.github.com/repos/cxlwill/hassbian-scripts/releases/latest | grep "browser_download_url.*deb" | cut -d : -f 2,3 | tr -d \" | wget -qi -

# Setting package name
HASSBIAN_PACKAGE=$(echo hassbian*.deb)

echo "安装最新版本脚本"
sudo apt install -y /tmp/"$HASSBIAN_PACKAGE"

echo "文件清理"
rm "$HASSBIAN_PACKAGE"

echo
echo "更新完成"
echo
return 0
}

[[ "$_" == "$0" ]] && echo "hassbian-config helper script; do not run directly, use hassbian-config instead"
