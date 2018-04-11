#!/bin/bash
function cloud9-show-short-info {
  printf "Cloud9 IDE\\n"
}

function cloud9-show-long-info {
  printf "安装 Cloud9 SDK \\n"
  printf "Cloud9 SDK 是一个在线 IDE，可以让你使用网页编辑配置文件\\n"
}

function cloud9-show-copyright-info {
  printf "原创：Ludeeus <https://github.com/ludeeus>.\\n"
  printf "本地化：墨澜 <http://cxlwill.cn>.\\n"
}

function cloud9-install-package {
node=$(which node)
if [ -z "${node}" ]; then #Installing NodeJS if not already installed.
  printf "下载及安装 NodeJS...\\n"
  curl -s https://deb.nodesource.com/gpgkey/nodesource.gpg.key | apt-key add -
  file="/etc/apt/sources.list.d/nodesource.list"
  if [ ! -f "$file" ]; then
    touch "$file"
    echo 'deb https://mirrors.tuna.tsinghua.edu.cn/nodesource/deb_9.x stretch main' > $file
    echo 'deb-src https://mirrors.tuna.tsinghua.edu.cn/nodesource/deb_9.x stretch main' >> $file
  fi
  apt install -y nodejs
  printf "配置淘宝源...\\n"
  npm config set registry https://registry.npm.taobao.org
fi

echo "创建配置文件夹..."
mkdir /opt/c9sdk
chown homeassistant:homeassistant /opt/c9sdk

echo "切换至 homeassistant 用户"
sudo -u homeassistant -H /bin/bash << EOF
  printf "下载及安装 Cloud9 SDK...\\n"
  git clone git://github.com/c9/core.git /opt/c9sdk
  bash /opt/c9sdk/scripts/install-sdk.sh
  echo '{"projecttree": {"@showhidden": true,"@hiddenFilePattern": ".n*,*c9*,.b*,.p*,.w*,*.db"}}' | tee /home/homeassistant/.c9/user.settings
EOF

echo "复制 Cloud9 服务文件..."
cp /opt/hassbian/suites/files/cloud9.service /etc/systemd/system/cloud9@homeassistant.service

echo "启用 Cloud9 服务..."
systemctl enable cloud9@homeassistant.service
sync

echo "启动 Cloud9..."
systemctl start cloud9@homeassistant.service

echo "安装检查..."
ip_address=$(ifconfig | grep "inet.*broadcast" | grep -v 0.0.0.0 | awk '{print $2}')
validation=$(pgrep -f cloud9)
if [ ! -z "${validation}" ]; then
  echo
  echo -e "\\e[32m安装完成\\e[0m"
  echo "你的 Cloud9 IDE 运行在 http://$ip_address:8181"
  echo
else
  echo
  echo -e "\\e[31m安装失败..."
  echo
    return 1
fi
return 0
}

function cloud9-upgrade-package {
printf "停止 Cloud9 服务...\\n"
systemctl stop cloud9@homeassistant.service
sudo -u homeassistant -H /bin/bash << EOF
  printf "下载及安装最新版本 Cloud9 SDK...\\n"
  git clone git://github.com/c9/core.git /opt/c9sdk
  bash /opt/c9sdk/scripts/install-sdk.sh
EOF

printf "启动 Cloud9...\\n"
systemctl start cloud9@homeassistant.service

echo "安装检查..."
validation=$(pgrep -f cloud9)
if [ ! -z "${validation}" ]; then
  echo
  echo -e "\\e[32m升级完成\\e[0m"
  echo
else
  echo
  echo -e "\\e[31m升级失败..."
  echo
    return 1
fi
return 0
}

function cloud9-remove-package {
printf "卸载 Cloud9 IDE...\\n"
systemctl stop cloud9@homeassistant.service
systemctl disable cloud9@homeassistant.service
rm /etc/systemd/system/cloud9@homeassistant.service
sync
bash /opt/c9sdk/scripts/uninstall-c9.sh
rm -R /opt/c9sdk

printf "\\e[32m卸载完成..\\e[0m\\n"
}
[[ "$_" == "$0" ]] && echo "hassbian-config helper script; do not run directly, use hassbian-config instead"
