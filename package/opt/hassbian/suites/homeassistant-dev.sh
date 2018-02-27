#!/bin/bash
function homeassistant-dev-show-short-info {
  echo "Home Assistant 开发版安装脚本"
}

function homeassistant-dev-show-long-info {
  echo "安装 Home Assistant 智能家居系统开发版"
}

function homeassistant-dev-show-copyright-info {
  echo "Copyright(c) 2017 Fredrik Lindqvist <https://github.com/Landrash>."
  echo "本地化：墨澜 <http://cxlwill.cn>"
}

function homeassistant-dev-install-package {
homeassistant-dev-show-short-info
homeassistant-dev-show-copyright-info

echo "停止 Home Assistant"
systemctl stop home-assistant@homeassistant.service
sync

echo "切换至 homeassistant 用户"
sudo -u homeassistant -H /bin/bash << EOF

echo "创建 Home Assistant 运行虚拟环境"
python3 -m venv /srv/homeassistant

echo "进入 Home Assistant 虚拟环境"
source /srv/homeassistant/bin/activate

echo "安装开发版本 Home Assistant"
pip3 install git+https://github.com/home-assistant/home-assistant@dev

echo "退出虚拟环境"
deactivate
EOF

echo "启用 Home Assistant 系统服务"
systemctl enable home-assistant@homeassistant.service
sync

echo "启动 Home Assistant"
systemctl start home-assistant@homeassistant.service

ip_address=$(ifconfig | awk -F':' '/inet addr/&&!/127.0.0.1/{split($2,_," ");print _[1]}')

echo "安装检查..."
validation=$(pgrep -x hass)
if [ ! -z "${validation}" ]; then
  echo
  echo -e "\\e[32m安装完成..\\e[0m"
  echo "Home Assistant 运行在 $ip_address:8123"
  echo "初次启动需要安装依赖包，请稍等片刻再打开网页"
  echo -e "\\e[0m对此脚本有任何疑问或建议, 欢迎加QQ群515348788讨论"
  echo
else
  echo
  echo -e "\\e[31m安装失败..."
  echo -e "\\e[31m退出..."
  echo -e "\\e[0m对此脚本有任何疑问或建议, 欢迎加QQ群515348788讨论"
  echo
  return 1
fi
return 0
}

[[ "$_" == "$0" ]] && echo "hassbian-config helper script; do not run directly, use hassbian-config instead"
