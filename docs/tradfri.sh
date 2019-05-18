#!/bin/bash

function tradfri-show-short-info {
    echo "宜家 Tradfri 网关"
}

function tradfri-show-long-info {
    echo "Installs the libraries needed to control IKEA Tradfri devices from this Pi."
}

function tradfri-show-copyright-info {
  echo "智能家居控制中心"
  echo "Copyright(c) 2019 Davis Pan <E-mail：Davis.Pan@outlook.com>"
}

function tradfri-install-package {
echo "Running apt-get preparation"
apt-get update
apt-get install -y dh-autoreconf

echo "Changing to homeassistant user"
sudo -u homeassistant -H /bin/bash <<EOF

echo "Activating Home Assistant venv"
source /srv/homeassistant/bin/activate

echo "Installing dependencies for Tradfri."
python3 -m pip install --upgrade pip setuptools wheel
python3 -m pip install cython

echo "Deactivating virtualenv"
deactivate
EOF

echo "Checking the installation..."
validation=$(sudo -u homeassistant -H /bin/bash << EOF | grep Version | awk '{print $2}'
source /srv/homeassistant/bin/activate
pip3 show cython
EOF
)
if [ ! -z "${validation}" ]; then
  echo
  echo -e "\\e[32mInstallation done..\\e[0m"
  echo
  echo "To continue have a look at https://home-assistant.io/components/tradfri/"
  echo "It's recommended that you restart your Tradfri Gateway before continuing."
  echo
else
  echo
  echo -e "\\e[31mInstallation failed..."
  echo
  return 1
fi
return 0
}

[[ "$_" == "$0" ]] && echo "hassbian-config helper script; do not run directly, use hassbian-config instead"
