#!/bin/bash
function homebridge-show-short-info {
  echo "Homebridge"
}

function homebridge-show-long-info {
  echo "安装及配置 Homebridge"
	echo "安装后你将可以通过 Homekit 控制 Home Assistant"
}

function homebridge-show-copyright-info {
	echo "原创：Ludeeus <https://github.com/ludeeus>"
	echo "部分脚本受启发于 Dale Higgs <https://github.com/dale3h>"
  echo "本地化：墨澜 <http://cxlwill.cn>"
}

function homebridge-install-package {
if [ "$ACCEPT" == "true" ]; then
  HOMEASSISTANT_URL="http://127.0.0.1:8123"
  HOMEASSISTANT_PASSWORD=""
else
  echo ""
  echo "请进行 Homebridge 相关设置..."
  echo ""
  echo "例如：https://home.duckdns.org:8123"
  echo -n "输入你的 Home Assistant URL，如带端口请包含"
  read -r HOMEASSISTANT_URL
  if [ ! "$HOMEASSISTANT_URL" ]; then
      HOMEASSISTANT_URL="http://127.0.0.1:8123"
  fi
  echo ""
  echo ""
  echo -n "请输入 Home Assistant 密码，如无直接回车"
  read -s -r HOMEASSISTANT_PASSWORD
  echo
fi

if [ "$ACCEPT" != "true" ]; then
  if [ -f "/usr/sbin/samba" ]; then
    echo -n "是否对 Homebridge 配置文件开启 Samba 共享？ [N/y] : "
    read -r SAMBA
  fi
fi

echo "系统准备及依赖安装..."
sudo apt update
sudo apt -y upgrade
node=$(which node)
if [ -z "${node}" ]; then #Installing NodeJS if not already installed.
  printf "下载及安装 NodeJS...\\n"
  curl -sL https://deb.nodesource.com/setup_9.x | bash -
  apt install -y nodejs
fi
sudo apt install -y libavahi-compat-libdnssd-dev

echo "切换为淘宝镜像源"
sudo npm config set registry https://registry.npm.taobao.org

echo "安装 Homebridge 及 Home Assistant 联动插件"
sudo npm install -g --unsafe-perm homebridge hap-nodejs node-gyp
sudo npm install -g homebridge-homeassistant

echo "添加 homebridge 用户并创建配置文件..."
sudo useradd --system --create-home homebridge
sudo mkdir /home/homebridge/.homebridge
sudo touch /home/homebridge/.homebridge/config.json
HOMEBRIDGE_PIN=$(printf "%03d-%02d-%03d" $((RANDOM % 999)) $((RANDOM % 99)) $((RANDOM % 999)))
HOMEBRIDGE_USERNAME=$(hexdump -n3 -e'/3 "00:60:2F" 3/1 ":%02X"' /dev/random)
HOMEBRIDGE_PORT=$( printf "57%03d" $((RANDOM % 999)))
cat > /home/homebridge/.homebridge/config.json <<EOF
{
  "bridge": {
    "name": "Homebridge",
    "username": "${HOMEBRIDGE_USERNAME}",
    "port": ${HOMEBRIDGE_PORT},
    "pin": "${HOMEBRIDGE_PIN}"
  },
  "description": "Homebridge 示例配置",
  "accessories": [
  ],
  "platforms": [
    {
      "platform": "HomeAssistant",
      "name": "HomeAssistant",
      "host": "${HOMEASSISTANT_URL}",
      "password": "${HOMEASSISTANT_PASSWORD}",
      "supported_types": ["automation", "binary_sensor", "climate", "cover", "device_tracker", "fan", "group", "input_boolean", "light", "lock", "media_player", "remote", "scene", "script", "sensor", "switch", "vacuum"],
	    "default_visibility": "visible"
    }
  ]
}
EOF
sudo chown -R homebridge /home/homebridge

echo "创建系统服务"
cat > /etc/systemd/system/homebridge.service <<EOF
[Unit]
Description=Node.js HomeKit Server

After=syslog.target network-online.target

[Service]
Type=simple
User=homebridge
ExecStart=/usr/bin/homebridge
Restart=on-failure
RestartSec=10
KillMode=process

[Install]
WantedBy=multi-user.target
EOF

echo "启用并启动 Homebridge 服务"
sudo systemctl daemon-reload
sudo systemctl enable homebridge.service
sudo systemctl start homebridge.service

if [ "$SAMBA" == "y" ] || [ "$SAMBA" == "Y" ]; then
	echo "添加配置至 Samba..."
	sudo smbpasswd -a homebridge -n
	echo "[homebridge]" | tee -a /etc/samba/smb.conf
	echo "path = /home/homebridge/.homebridge" | tee -a /etc/samba/smb.conf
	echo "writeable = yes" | tee -a /etc/samba/smb.conf
	echo "guest ok = yes" | tee -a /etc/samba/smb.conf
	echo "create mask = 0644" | tee -a /etc/samba/smb.conf
	echo "directory mask = 0755" | tee -a /etc/samba/smb.conf
	echo "force user = homebridge" | tee -a /etc/samba/smb.conf
	echo "" | tee -a /etc/samba/smb.conf
	echo "重启 Samba 服务"
	sudo systemctl restart smbd.service
fi

echo "安装检查..."
validation=$(pgrep -f homebridge)
if [ ! -z "${validation}" ]; then
  echo
  echo -e "\\e[32m安装完成\\e[0m"
  echo
  echo "Homebridge 已启动你可以使用 家庭 应用添加设备"
  echo "添加时 PIN 码为 '$HOMEBRIDGE_PIN'"
  echo "欢迎阅读相关中文文档：https://home-assistant.cc/project/homebridge/"
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


[[ "$_" == "$0" ]] && echo "hassbian-config helper script; do not run directly, use hassbian-config instead"
