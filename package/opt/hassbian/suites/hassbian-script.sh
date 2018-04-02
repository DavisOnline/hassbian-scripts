#!/bin/bash
function hassbian-script-show-short-info {
    echo "Hassbian-Script upgrade script for Hassbian"
}

function hassbian-script-show-long-info {
    echo "更新汉化版 hassbian-scripts"
}

function hassbian-script-show-copyright-info {
    echo "原创：Ludeeus <https://github.com/ludeeus>"
    echo "本地化：墨澜 <http://cxlwill.cn>"
}

function hassbian-script-upgrade-package {

if [ "$DEV" == "true"  ]; then
  echo "此脚本将从 Github 下载开发版 hassbian-scripts"
  echo "以帮助你进行 Hassbian 的相关开发"
  echo "不推荐将开发版用于日常生产环境"
  echo -n "确定继续? [N/y] : "
  read -r RESPONSE
  if [ "$RESPONSE" == "y" ] || [ "$RESPONSE" == "Y" ]; then
    RESPONSE="Y"
  else
    echo "退出..."
    return 0
  fi
  echo "创建临时文件夹"
  cd || exit
  sudo mkdir /tmp/hassbian_config_update
  cd /tmp/hassbian_config_update || exit

  echo "下载最新脚本"
  curl -L https://api.github.com/repos/cxlwill/hassbian-scripts/tarball| sudo tar xz --strip=1

  echo "移动脚本至安装文件夹"
  yes | sudo cp -rf /tmp/hassbian_config_update/package/usr/local/bin/hassbian-config /usr/local/bin/hassbian-config
  yes | sudo cp -rf /tmp/hassbian_config_update/package/opt/hassbian/suites/* /opt/hassbian/suites/

  echo "删除临时文件夹"
  cd || exit
  sudo rm -r /tmp/hassbian_config_update
else
  echo "切换至临时文件夹"
  cd /tmp || exit

  echo "下载最新更新"
  if [ "$BETA" == "true"  ]; then
    echo "检查是否有可用预先发行版本..."
    prerelease=$(curl https://api.github.com/repos/cxlwill/hassbian-scripts/releases | grep '"prerelease": true')
    if [ ! -z "${prerelease}" ]; then
      echo "存在预先发行版本..."
      curl https://api.github.com/repos/cxlwill/hassbian-scripts/releases | grep "browser_download_url.*deb" | head -1 | cut -d : -f 2,3 | tr -d \" | wget -qi -
    else
      echo "未找到预先发行版本..."
      echo "下载最新稳定版..."
      curl https://api.github.com/repos/cxlwill/hassbian-scripts/releases/latest | grep "browser_download_url.*deb" | cut -d : -f 2,3 | tr -d \" | wget -qi -
    fi
  else
    curl https://api.github.com/repos/cxlwill/hassbian-scripts/releases/latest | grep "browser_download_url.*deb" | cut -d : -f 2,3 | tr -d \" | wget -qi -
  fi

  HASSBIAN_PACKAGE=$(echo hassbian*.deb)

  echo "安装脚本"
  downloadedversion=$(echo "$HASSBIAN_PACKAGE" | awk -F'_' '{print $2}' | cut -d . -f 1,2,3)
  currentversion=$(hassbian-config -V)
  if [[ "$currentversion" > "$downloadedversion" ]]; then
    apt install -y /tmp/"$HASSBIAN_PACKAGE" --allow-downgrades
  else
    apt install -y /tmp/"$HASSBIAN_PACKAGE" --reinstall
  fi
  echo "Cleanup"
  rm "$HASSBIAN_PACKAGE"
fi
echo
echo "更新完成"
echo
return 0
}

[[ "$_" == "$0" ]] && echo "hassbian-config helper script; do not run directly, use hassbian-config instead"
