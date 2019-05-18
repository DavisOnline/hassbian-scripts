#!/bin/bash
function python-show-short-info {
  echo "升级系统 python3 至最新稳定版"
}

function python-show-long-info {
  echo "升级系统 python3 至最新稳定版"
}

function python-show-copyright-info {
  echo "智能家居控制中心"
  echo "Copyright(c) 2019 Davis Pan <E-mail：Davis.Pan@outlook.com>"
}

function python-upgrade-package {
if [ "$FORCE" == "" ]; then
  printf "\\n\\n"
  echo "此脚本将会对你小 pi 产生重大影响！"
  echo "请十拿九稳加三思后再决定执行此脚本！"
  echo "考虑后请强制执行此脚本:"
  echo "sudo hassbian-config upgrade python --force"
  return 0
fi

printf "\\n\\n"
echo "我们真的不太推荐运行此脚本"
echo -n "你真的准备好了? [N/y]: "
read -r RESPONSE
if [ "$RESPONSE" == "y" ] || [ "$RESPONSE" == "Y" ]; then
  RESPONSE="Y"
else
  return 0
fi

PYTHONVERSION=$(curl -s https://www.python.org/downloads/source/ | grep "Latest Python 3 Release" | cut -d "<" -f 3 | awk -F ' ' '{print $NF}')

echo "检查当前版本..."
currentpython=$(sudo -u homeassistant -H /bin/bash << EOF | awk -F ' ' '{print $NF}'
source /srv/homeassistant/bin/activate
python -V
EOF
)

if [ "$currentpython" == "$PYTHONVERSION" ]; then
  echo "Python 已是最新稳定版.."
  return 0
fi
echo "升级至 Python $PYTHONVERSION"
apt-get -y update
apt-get install -y build-essential tk-dev libncurses5-dev libncursesw5-dev libreadline6-dev libdb5.3-dev libgdbm-dev libsqlite3-dev libssl-dev libbz2-dev libexpat1-dev liblzma-dev zlib1g-dev
apt-get install libtcmalloc-minimal4
export LD_PRELOAD="/usr/lib/libtcmalloc_minimal.so.4"
cd /tmp || return 1
wget https://www.python.org/ftp/python/"$PYTHONVERSION"/Python-"$PYTHONVERSION".tar.xz
tar xf Python-"$PYTHONVERSION".tar.xz
cd Python-"$PYTHONVERSION" || return 1
./configure
make altinstall
apt -y autoremove
cd  || return 1
rm -r /tmp/Python-"$PYTHONVERSION"
rm /tmp/Python-"$PYTHONVERSION".tar.xz
echo "完成"

echo "停止 Home Assistant"
systemctl stop home-assistant@homeassistant.service

echo "备份原虚拟环境"
mv /srv/homeassistant /srv/homeassistant_"$currentpython"

echo "使用 Python $PYTHONVERSION 创建新的虚拟环境"
python"${PYTHONVERSION:: -2}" -m venv /srv/homeassistant
mv /srv/homeassistant_"$currentpython"/hassbian /srv/homeassistant/hassbian
chown homeassistant:homeassistant -R /srv/homeassistant
apt install python3-pip python3-dev
pip"${PYTHONVERSION:: -2}" install --upgrade virtualenv
sudo -u homeassistant -H /bin/bash << EOF
source /srv/homeassistant/bin/activate
pip3 install --upgrade setuptools wheel
pip3 install --upgrade homeassistant
deactivate
EOF
mv /home/homeassistant/.homeassistant/deps /home/homeassistant/.homeassistant/deps_"$currentpython"

echo "启动 Home Assistant."
systemctl start home-assistant@homeassistant.service

echo "安装检查..."
validation=$(sudo -u homeassistant -H /bin/bash << EOF | awk -F ' ' '{print $NF}'
source /srv/homeassistant/bin/activate
python -V
EOF
)
if [ "$validation" == "$PYTHONVERSION" ]; then
  echo
  echo -e "\\e[32m升级完成..\\e[0m"
  echo "Home Assistant 等于重新安装初次启动，需要等待一段时间下载依赖包不要心急"
  echo "你可以运行 'sudo journalctl -u home-assistant@homeassistant.service -f' 查看 HA log."
  echo
else
  echo
  echo -e "\\e[31m升级失败..."
  echo -e "\\e[31m恢复..."
  systemctl stop home-assistant@homeassistant.service
  rm -R /srv/homeassistant
  mv /srv/homeassistant_"$currentpython" /srv/homeassistant
  systemctl start home-assistant@homeassistant.service
  echo
  return 1
fi
return 0
}

[[ "$_" == "$0" ]] && echo "hassbian-config helper script; do not run directly, use hassbian-config instead"
