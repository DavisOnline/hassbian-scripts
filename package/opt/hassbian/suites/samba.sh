#!/bin/bash

function samba-show-short-info {
  echo "Samba 文件共享"
}

function samba-show-long-info {
  echo "安装 Samba 以共享文件"
}

function samba-show-copyright-info {
  echo "Copyright(c) 2017 Fredrik Lindqvist <https://github.com/Landrash>."
  echo "本地化：墨澜 <http://cxlwill.cn>"
}

function samba-install-package {

samba-show-short-info
samba-show-copyright-info

echo "安装软件"
apt-get update
apt-get install -y samba

echo "添加 homeassistant Samba 用户"
sudo smbpasswd -a homeassistant -n

echo "共享 Home Assistant 配置文件夹"
cd /etc/samba/ || exit
sudo patch <<'EOF'
--- smb.conf 2017-02-02 20:29:42.383603738 +0000
+++ smb_ha.conf 2017-02-02 20:37:12.418960977 +0000
@@ -252,3 +252,11 @@
 # to the drivers directory for these users to have write rights in it
 ;   write list = root, @lpadmin

+[homeassistant]
+path = /home/homeassistant/.homeassistant
+writeable = yes
+guest ok = yes
+create mask = 0644
+directory mask = 0755
+force user = homeassistant
+
EOF


echo "重启 Samba 服务"
sudo systemctl restart smbd.service

ip_address=$(ifconfig | grep "inet.*broadcast" | grep -v 0.0.0.0 | awk '{print $2}')

echo "安装检查..."
validation=$(pgrep -x smbd)
if [ ! -z "${validation}" ]; then
  echo
  echo -e "\\e[32m安装完成..\\e[0m"
  echo
  echo "你的 HA 配置文件共享在 \\\\$ip_address\\homeassistant"
  echo
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
