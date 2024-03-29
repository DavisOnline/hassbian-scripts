#!/bin/bash

function libcec-show-short-info {
  echo "Libcec HDMI"
}

function libcec-show-long-info {
  echo "Installs the libcec package for controlling CEC devices from this Pi."
}

function libcec-show-copyright-info {
  echo "智能家居控制中心"
  echo "Copyright(c) 2019 Davis Pan <E-mail：Davis.Pan@outlook.com>"
}

function libcec-install-package {
echo "Running apt-get preparation"
apt-get update
apt-get install -y cmake libudev-dev libxrandr-dev swig

echo "Changing to homeassistant user"
sudo -u homeassistant -H /bin/bash <<EOF

echo "Creating source directory"
mkdir -p /srv/homeassistant/src
chown -R homeassistant:homeassistant /srv/homeassistant/src

echo "Cloning Pulse-Eight platform"
cd /srv/homeassistant/src
git clone https://github.com/Pulse-Eight/platform.git
chown homeassistant:homeassistant platform

echo "Building Pulse-Eight platform"
mkdir platform/build
cd platform/build
cmake ..
make
EOF

echo "Installing Pulse-Eight platform"
cd /srv/homeassistant/src/platform/build || exit
sudo make install
sudo ldconfig

echo "Changing back to homeassistant user"
sudo -u homeassistant -H /bin/bash <<EOF

echo "Cloning Pulse-Eight libcec"
cd /srv/homeassistant/src
git clone https://github.com/Pulse-Eight/libcec.git

echo "Building Pulse-Eight platform"
chown homeassistant:homeassistant libcec
mkdir libcec/build
cd libcec/build
cmake -DRPI_INCLUDE_DIR=/opt/vc/include -DRPI_LIB_DIR=/opt/vc/lib ..
make -j4
EOF

echo "Installing Pulse-Eight libcec"
cd /srv/homeassistant/src/libcec/build || exit
sudo make install
sudo ldconfig

echo "Linking libcec to venv site packages"
PYTHONVER=$(echo /usr/local/lib/*python* | awk -F/ '{print $NF}')
sudo -u homeassistant -H /bin/bash <<EOF
ln -s /usr/local/lib/$PYTHONVER/dist-packages/cec /srv/homeassistant/lib/$PYTHONVER/site-packages/
EOF

echo "Checking the installation..."
validation=$(which cec-client)
if [ ! -z "${validation}" ]; then
  echo
  echo -e "\\e[32mInstallation done..\\e[0m"
  echo
  echo "To continue have a look at https://home-assistant.io/components/hdmi_cec/"
  echo "It's recommended that you restart your Pi before continuing with testing libcec."
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
