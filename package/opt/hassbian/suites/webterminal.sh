#!/bin/bash
function webterminal-show-short-info {
  echo "安装网页终端"
}

function webterminal-show-long-info {
  echo "安装网页终端"
}

function webterminal-show-copyright-info {
	echo "原创：Ludeeus <https://github.com/ludeeus>"
  echo "本地化：墨澜 <http://cxlwill.cn>"
}

function webterminal-install-package {
echo "安装软件"
sudo apt-get install -y openssl shellinabox

echo "更改配置"
sudo sed -i 's/--no-beep/--no-beep --disable-ssl/g' /etc/default/shellinabox

echo "启动服务"
sudo service shellinabox reload
sudo service shellinabox restart

ip_address=$(ifconfig | grep "inet.*broadcast" | grep -v 0.0.0.0 | awk '{print $2}')

echo "安装检查..."
validation=$(pgrep -f shellinaboxd)
if [ ! -z "${validation}" ]; then
  echo
  echo -e "\\e[32m安装完成..\\e[0m"
  echo
  echo "现在可以通过 http://$ip_address:4200 访问终端"
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
