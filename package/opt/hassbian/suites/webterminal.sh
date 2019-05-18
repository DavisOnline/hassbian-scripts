#!/bin/bash
function webterminal-show-short-info {
  echo "网页版终端"
}

function webterminal-show-long-info {
  echo "安装网页终端"
}

function webterminal-show-copyright-info {
	echo "原创：Ludeeus <https://github.com/ludeeus>"
  echo "本地化：墨澜 <http://cxlwill.cn>"
}

function webterminal-install-package {

if [ "$ACCEPT" == "true" ]; then # True if `-y` flag is used.
  if [ -d "/etc/letsencrypt/live" ] || [ -d "/home/homeassistant/dehydrated/certs" ]; then
    SSL="Y"
  else
    SSL="N"
  fi
else
  echo ""
  echo -n "Do you use SSL (https) with Home Assistant? [N/y] : "
  read -r SSL
  if [ ! "$SSL" ]; then
      SSL="N"
  fi
fi

echo "安装软件"

sudo apt-get install -y openssl shellinabox

echo "更改配置"
sudo sed -i 's/--no-beep/--no-beep --disable-ssl/g' /etc/default/shellinabox
echo "Changing config."
if [ "$SSL" == "y" ] || [ "$SSL" == "Y" ]; then
  echo "No need to change default configuration, skipping this step..."
  echo "Checking cert directory..."
  if [ -d "/etc/letsencrypt/live" ]; then
    CERTDIR="/etc/letsencrypt/live/"
  elif [ -d "/home/homeassistant/dehydrated/certs" ]; then
    CERTDIR="/home/homeassistant/dehydrated/certs/"
  else
    CERTDIR=""
  fi
  echo "Merging files and adding to correct dir..."
  DOMAIN=$(ls "$CERTDIR")
  cat "$CERTDIR$DOMAIN/fullchain.pem" "$CERTDIR$DOMAIN/privkey.pem" > /var/lib/shellinabox/certificate-"$DOMAIN".pem
  chown shellinabox:shellinabox -R /var/lib/shellinabox/
  echo "Adding crong job to copy certs..."
  (crontab -l ; echo "5 1 1 * * bash /opt/hassbian/suites/files/webterminalsslhelper.sh >/dev/null 2>&1")| crontab -
else
  sed -i 's/--no-beep/--no-beep --disable-ssl/g' /etc/default/shellinabox
fi



echo "启动服务"
service shellinabox reload
service shellinabox stop
service shellinabox start


ip_address=$(ifconfig | grep "inet.*broadcast" | grep -v 0.0.0.0 | awk '{print $2}')


echo "安装检查..."
if [ "$SSL" == "y" ] || [ "$SSL" == "Y" ]; then
  PROTOCOL="https"
else
  PROTOCOL="http"
fi

echo "Checking the installation..."
validation=$(pgrep -f shellinaboxd)
if [ ! -z "${validation}" ]; then
  echo
  echo -e "\\e[32m安装完成..\\e[0m"
  echo
  echo "现在可以通过 $PROTOCOL://$ip_address:4200 访问终端"
  echo "你也可以把这个页面用 'panel_iframe' 组件添加到 Home-Assistant"
  echo
else
  echo
  echo -e "\\e[31m安装失败..."
  echo -e "\\e[31m正在退出..."
  echo -e "\\e[0m对此脚本有任何疑问或建议, 欢迎加QQ群515348788讨论"
  echo
  return 1
fi
return 0
}

[[ "$_" == "$0" ]] && echo "hassbian-config helper script; do not run directly, use hassbian-config instead"
