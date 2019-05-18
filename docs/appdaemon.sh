#!/bin/bash
function appdaemon-show-short-info {
  echo "AppDaemon"
}

function appdaemon-show-long-info {
  echo "在独立虚拟环境中安装 AppDaemon"
}

function appdaemon-show-copyright-info {
  echo "智能家居控制中心"
  echo "Copyright(c) 2019 Davis Pan <E-mail：Davis.Pan@outlook.com>"

}

function appdaemon-install-package {
if [ "$ACCEPT" != "true" ]; then
  if [ -f "/usr/sbin/samba" ]; then
    echo -n "是否对 AppDaemon 配置文件开启 Samba 文件共享？[N/y] : "
    read -r SAMBA
  fi
  echo -n "输入你的 Home Assistant 密码（无直接回车）: "
  read -s -r HOMEASSISTANT_PASSWORD
  printf "\\n"
else
  HOMEASSISTANT_PASSWORD=""
fi

echo "检查 Python 版本..."
PYTHONVER=$(echo /usr/local/lib/*python* | awk -F/ '{print $NF}')
echo "Using $PYTHONVER..."

echo "创建 AppDaemon 运行文件夹"
sudo mkdir /srv/appdaemon
sudo chown -R homeassistant:homeassistant /srv/appdaemon

echo "切换至 homeassistant 用户"
sudo -u homeassistant -H /bin/bash << EOF

echo "创建 AppDaemon 运行虚拟环境"
$PYTHONVER -m venv /srv/appdaemon

echo "进入 AppDaemon 虚拟环境"
source /srv/appdaemon/bin/activate

echo "创建 AppDaemon 配置文件夹"
mkdir /home/homeassistant/appdaemon
mkdir /home/homeassistant/appdaemon/apps

echo "安装最新版本 AppDaemon"
pip3 install wheel -i https://mirrors.aliyun.com/pypi/simple/
pip3 install appdaemon -i https://mirrors.aliyun.com/pypi/simple/

echo "生成 AppDaemon 配置文件"
cp /opt/hassbian/suites/files/appdaemon.conf /home/homeassistant/appdaemon/appdaemon.yaml
if [ ! -z "${HOMEASSISTANT_PASSWORD}" ]; then
    sed -i 's/#ha_key:/ha_key: $HOMEASSISTANT_PASSWORD/g' /home/homeassistant/appdaemon/appdaemon.yaml
fi

echo "退出虚拟环境"
deactivate
EOF

echo "生成 AppDaemon 系统服务文件"
sudo cp /opt/hassbian/suites/files/appdaemon.service /etc/systemd/system/appdaemon@homeassistant.service

echo "启用 AppDaemon 系统服务"
systemctl enable appdaemon@homeassistant.service
sync

echo "启动 AppDaemon"
systemctl start appdaemon@homeassistant.service

if [ "$SAMBA" == "y" ] || [ "$SAMBA" == "Y" ]; then
  echo "添加配置至 Samba..."
  echo "[appdaemon]" | tee -a /etc/samba/smb.conf
  echo "path = /home/homeassistant/appdaemon" | tee -a /etc/samba/smb.conf
  echo "writeable = yes" | tee -a /etc/samba/smb.conf
  echo "guest ok = yes" | tee -a /etc/samba/smb.conf
  echo "create mask = 0644" | tee -a /etc/samba/smb.conf
  echo "directory mask = 0755" | tee -a /etc/samba/smb.conf
  echo "force user = homeassistant" | tee -a /etc/samba/smb.conf
  echo "" | tee -a /etc/samba/smb.conf
  echo "重启 Samba 服务"
  sudo systemctl restart smbd.service
fi

echo "安装检查..."
validation=$(pgrep -f appdaemon)
if [ ! -z "${validation}" ]; then
  echo
  echo -e "\\e[32m安装完成..\\e[0m"
  echo
  echo "你的 AppDaemon 配置文件存放在:"
  echo "/home/homeassistant/appdaemon"
  echo
else
  echo
  echo -e "\\e[31m安装失败..."
  echo -e "\\e[31m退出..."
  echo
  return 1
fi
return 0
}

function appdaemon-upgrade-package {

appdaemon-show-short-info
appdaemon-show-copyright-info

echo "停止 AppDaemon 服务..."
systemctl stop appdaemon@homeassistant.service

echo "切换至 homeassistant 用户..."
sudo -u homeassistant -H /bin/bash << EOF

echo "进入 AppDaemon 虚拟环境..."
source /srv/appdaemon/bin/activate

echo "安装最新版本 AppDaemon..."
pip3 install wheel -i https://mirrors.aliyun.com/pypi/simple/
pip3 install --upgrade appdaemon -i https://mirrors.aliyun.com/pypi/simple/


echo "退出虚拟环境..."
deactivate
EOF

echo "启动 AppDaemon..."
systemctl start appdaemon@homeassistant.service

echo "安装检查..."
validation=$(pgrep -f appdaemon)
if [ ! -z "${validation}" ]; then
  echo
  echo -e "\\e[32m更新完成..\\e[0m"
  echo
else
  echo
  echo -e "\\e[31m更新失败..."
  echo -e "\\e[31m退出..."
  echo
  return 1
fi
return 0
}
[[ "$_" == "$0" ]] && echo "hassbian-config helper script; do not run directly, use hassbian-config instead"
