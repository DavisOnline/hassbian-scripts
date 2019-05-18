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
pip3 install setuptools wheel
pip3 install homeassistant

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
if [ "$DEV" == "true"  ]; then
  echo "此脚本将通过 Github 安装开发版 Home Assistant."
  echo "以帮助你进行 Home Assistant 相关开发工作."
  echo "不推荐将开发版用于日常使用环境"
  echo -n "确定继续? [N/y] : "
  read -r RESPONSE
  if [ "$RESPONSE" == "y" ] || [ "$RESPONSE" == "Y" ]; then
    RESPONSE="Y"
  else
    echo "退出..."
    return 0
  fi
else
  echo "检查当前版本"
  if [ "$BETA" == "true"  ]; then
  newversion=$(curl -s https://api.github.com/repos/home-assistant/home-assistant/releases | grep tag_name | head -1 | awk -F'"' '{print $4}')
  elif [ ! -z "${VERSIONNUMBER}" ]; then
    verify=$(curl -s https://pypi.org/pypi/homeassistant/"$VERSIONNUMBER"/json)
    if [[ "$verify" = *"Not Found"* ]]; then
      echo "版本 $VERSIONNUMBER 未找到..."
      echo "退出..."
      return 0
    else
      newversion="$VERSIONNUMBER"
    fi
  else
    newversion=$(curl -s https://api.github.com/repos/home-assistant/home-assistant/releases/latest | grep tag_name | awk -F'"' '{print $4}')
  fi
  sudo -u homeassistant -H /bin/bash << EOF | grep Version | awk '{print $2}'|while read -r version; do if [[ "${newversion}" == "${version}" ]]; then echo "You already have version: $version";exit 1;fi;done
  source /srv/homeassistant/bin/activate
  pip3 show homeassistant
EOF

  if [[ $? == 1 ]]; then
    echo "更新中止"
    exit 1
  fi
fi

echo "停止 Home Assistant"
systemctl stop home-assistant@homeassistant.service

echo "切换至 homeassistant 用户"
sudo -u homeassistant -H /bin/bash << EOF

echo "进入 Home Assistant 虚拟环境"
source /srv/homeassistant/bin/activate

echo "升级 Home Assistant"
pip3 install --upgrade setuptools wheel
if [ "$DEV" == "true" ]; then
  pip3 install git+https://github.com/home-assistant/home-assistant@dev
elif [ "$BETA" == "true" ]; then
  pip3 install --upgrade --pre homeassistant
else
  pip3 install --upgrade homeassistant=="$newversion"
fi

echo "退出虚拟环境"
deactivate
EOF

if [ "$FORCE" != "true"  ]; then
  current_version=$(cat /home/homeassistant/.homeassistant/.HA_VERSION)
  config_check=$(sudo -u homeassistant -H /bin/bash << EOF
  source /srv/homeassistant/bin/activate
  hass --script check_config -c /home/homeassistant/.homeassistant/
EOF
  )
  config_check_lines=$(echo "$config_check" | wc -l)
  if (( config_check_lines > 1 ));then
    if [ "$ACCEPT" != "true" ]; then
      echo -n "Config check failed for new version, do you want to revert? [Y/n] : "
      read -r RESPONSE
      if [ ! "$RESPONSE" ]; then
        RESPONSE="Y"
      fi
    else
      RESPONSE="Y"
    fi
    if [ "$RESPONSE" == "y" ] || [ "$RESPONSE" == "Y" ]; then
      sudo -u homeassistant -H /bin/bash << EOF
      source /srv/homeassistant/bin/activate
      pip3 install --upgrade homeassistant=="$current_version"
      deactivate
EOF
    fi
  fi
fi

echo "重启 Home Assistant"
systemctl restart home-assistant@homeassistant.service

echo "安装检查..."
validation=$(pgrep -x hass)
if [ ! -z "${validation}" ]; then
  echo
  echo -e "\\e[32m更新完成..\\e[0m"
  echo "注意更新后需要一定时间启动"
  echo
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
