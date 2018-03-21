#!/bin/bash
function homeassistant-show-short-info {
  echo "Home Assistant 系统"
}

function homeassistant-show-long-info {
  echo "安装 Home Assistant 智能家居系统"
}

function homeassistant-show-copyright-info {
  echo "Copyright(c) 2017 Fredrik Lindqvist <https://github.com/Landrash>."
  echo "本地化：墨澜 <http://cxlwill.cn>"
}

function homeassistant-install-package {

homeassistant-show-short-info
homeassistant-show-copyright-info

echo "切换至 homeassistant 用户"
sudo -u homeassistant -H /bin/bash << EOF

echo "创建 Home Assistant 运行虚拟环境"
python3 -m venv /srv/homeassistant

echo "进入 Home Assistant 虚拟环境"
source /srv/homeassistant/bin/activate

echo "安装最新版本 Home Assistant"
pip3 install setuptools wheel -i https://mirrors.aliyun.com/pypi/simple/
pip3 install homeassistant -i https://mirrors.aliyun.com/pypi/simple/

echo "退出虚拟环境"
deactivate
EOF

echo "启用 Home Assistant 系统服务"
systemctl enable home-assistant@homeassistant.service
sync

echo "禁用 Home Assistant 初始安装脚本"
systemctl disable install_homeassistant
systemctl daemon-reload

echo "启动 Home Assistant"
systemctl start home-assistant@homeassistant.service

ip_address=$(ifconfig | grep "inet.*broadcast" | grep -v 0.0.0.0 | awk '{print $2}')

echo "安装检查..."
validation=$(pgrep -x hass)
if [ ! -z "${validation}" ]; then
  echo
  echo -e "\\e[32m安装完成..\\e[0m"
  echo "Home Assistant 运行在 $ip_address:8123"
  echo "初次启动需要安装依赖包，请稍等片刻再打开网页"
  echo "欢迎阅读相关英文文档：https://home-assistant.io/getting-started/configuration/"
  echo "欢迎阅读 HA 中文文档：https://home-assistant.cc"
  echo -e "\\e[0m对此脚本有任何疑问或建议, 欢迎加QQ群515348788讨论"
else
  echo
  echo -e "\\e[31m安装失败..."
  echo -e "\\e[31m退出..."
  echo -e "\\e[0m对此脚本有任何疑问或建议, 欢迎加QQ群515348788讨论"
  echo -e "\\e[0mHome Assistant入门视频教程：http://t.cn/RQPeEQv"
  echo
  return 1
fi
return 0
}

function homeassistant-upgrade-package {

homeassistant-show-short-info
homeassistant-show-copyright-info

echo "检查当前版本"
pypiversion=$(curl -s https://pypi.python.org/pypi/homeassistant/json | grep '"version":' | awk -F'"' '{print $4}')

sudo -u homeassistant -H /bin/bash << EOF | grep Version | awk '{print $2}'|while read -r version; do if [[ "${pypiversion}" == "${version}" ]]; then echo "You already have the latest version: $version";exit 1;fi;done
source /srv/homeassistant/bin/activate
pip3 show homeassistant
EOF

if [[ $? == 1 ]]; then
  echo "已是最新版本更新个啥"
  exit 1
fi

echo "停止 Home Assistant"
systemctl stop home-assistant@homeassistant.service

echo "切换至 homeassistant 用户"
sudo -u homeassistant -H /bin/bash << EOF

echo "进入 Home Assistant 虚拟环境"
source /srv/homeassistant/bin/activate

echo "安装最新版本 Home Assistant"
pip3 install --upgrade setuptools wheel -i https://mirrors.aliyun.com/pypi/simple/
pip3 install --upgrade homeassistant -i https://mirrors.aliyun.com/pypi/simple/

echo "退出虚拟环境"
deactivate
EOF

echo "重启 Home Assistant"
systemctl start home-assistant@homeassistant.service

echo "安装检查..."
validation=$(pgrep -x hass)
if [ ! -z "${validation}" ]; then
  echo
  echo -e "\\e[32m更新完成..\\e[0m"
  echo "更新后初次启动需要安装依赖包，请稍等片刻再打开网页"
  echo -e "\\e[0m对此脚本有任何疑问或建议, 欢迎加QQ群515348788讨论"
else
  echo
  echo -e "\\e[31m更新失败..."
  echo -e "\\e[31m退出..."
  echo -e "\\e[0m对此脚本有任何疑问或建议, 欢迎加QQ群515348788讨论"
  echo -e "\\e[0mHome Assistant入门视频教程：http://t.cn/RQPeEQv"
  echo
  return 1
fi
return 0
}

[[ "$_" == "$0" ]] && echo "hassbian-config helper script; do not run directly, use hassbian-config instead"
