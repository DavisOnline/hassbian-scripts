#!/bin/bash
function nodered-show-short-info {
  echo "Node-RED"
}

function nodered-show-long-info {
  echo "安装及配置 Node-RED"
  echo "安装后你可以使用 Node-RED 进行自动化的可视化配置"
}

function nodered-show-copyright-info {
  echo "智能家居控制中心"
  echo "Copyright(c) 2019 Davis Pan <E-mail：Davis.Pan@outlook.com>"
}

function nodered-install-package {
echo "系统准备及依赖安装..."
sudo apt update
sudo apt -y upgrade
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
  apt update
  apt install -y nodejs
fi

echo "切换为淘宝镜像源"
sudo npm config set registry https://registry.npm.taobao.org

echo "安装 Node-RED 及 Home Assistant 联动插件"
sudo npm install -g --unsafe-perm node-red
cd ~/.node-red
npm install node-red-contrib-home-assistant

echo "设置自动启动"
sudo wget https://raw.githubusercontent.com/node-red/raspbian-deb-package/master/resources/nodered.service -O /lib/systemd/system/nodered.service
sudo wget https://raw.githubusercontent.com/node-red/raspbian-deb-package/master/resources/node-red-start -O /usr/bin/node-red-start
sudo wget https://raw.githubusercontent.com/node-red/raspbian-deb-package/master/resources/node-red-stop -O /usr/bin/node-red-stop
sudo chmod +x /usr/bin/node-red-st*
sudo systemctl daemon-reload
sudo systemctl enable nodered.service

echo "启动 Node-RED"
sudo systemctl start nodered.service
sleep 2

ip_address=$(ifconfig | grep "inet.*broadcast" | grep -v 0.0.0.0 | awk '{print $2}')

echo "安装检查..."
validation=$(pgrep -x node-red)
if [ ! -z "${validation}" ]; then
  echo
  echo -e "\\e[32m安装完成..\\e[0m"
  echo "Node-RED 运行在 $ip_address:1880"
else
  echo
  echo -e "\\e[31m安装失败..."
  echo -e "\\e[31m退出..."
  echo
  return 1
fi
return 0
}


