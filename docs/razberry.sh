#!/bin/bash

function razberry-show-short-info {
  echo "关闭 Hassbian 中的蓝牙服务"
}

function razberry-show-long-info {
  echo "Disables Bluetooth for the use of a RaZberry with Hassbian."
  echo "This will disable the use of Bluetooth and BLE devices."
  echo " "
  echo "Original script from http://razberry.z-wave.me/install"
}

function razberry-show-copyright-info {
  echo "智能家居控制中心"
  echo "Copyright(c) 2019 Davis Pan <E-mail：Davis.Pan@outlook.com>"
}

function razberry-install-package {
echo "Checking for version of Raspberry Pi"
RPI_BOARD_REVISION=$(grep Revision /proc/cpuinfo | cut -d: -f2 | tr -d " ")
if [[ $RPI_BOARD_REVISION ==  "a02082" || $RPI_BOARD_REVISION == "a22082" ]]
then
  echo "Raspberry Pi 3 Detected. Disabling Bluetooth"
  systemctl disable hciuart
  if ! grep -q "dtoverlay=pi3-miniuart-bt" /boot/config.txt
  then
    echo "Adding 'dtoverlay=pi3-miniuart-bt' to /boot/config.txt"
    echo "dtoverlay=pi3-miniuart-bt" >> /boot/config.txt
  fi
fi

validation=$(grep "dtoverlay=pi3-miniuart-bt" /boot/config.txt)
if [ ! -z "${validation}" ]; then
  echo
  echo -e "\\e[32mInstallation done..\\e[0m"
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
