#!/bin/bash
function duckdns-show-short-info {
  echo "Duck DNS 自动更新及 SSL 证书自动生成"
}

function duckdns-show-long-info {
  echo "此脚本将添加定时任务用来更新你的动态 IP 地址"
  echo "此脚本还将使用 Let’s Encrypt 自动生成 SSL 证书"
}

function duckdns-show-copyright-info {
  echo "原创：Ludeeus <https://github.com/ludeeus>."
  echo "本地化：cxlwill <http://cxlwill.cn>."
}

function duckdns-install-package {
echo "Please take a moment to setup autorenewal of duckdns."
echo "If no choice is made the installation will exit."
echo
echo "(if your domain is 'example.duckdns.org' type example)"
echo -n "Domain: "
read -r domain
if [ ! "$domain" ]; then
  exit
fi
if [[ $domain = *"duckdns"* ]]; then
  domain=$(echo "$domain" | cut -d\. -f1)
fi
if [[ $domain = *"//"* ]]; then
  domain=$(echo "$domain" | cut -d/ -f3)
fi


echo -n "Token: "
read -r token
echo
if [ ! "$token" ]; then
  exit
fi
echo -n "Do you want to generate certificates to use SSL(https)? [N/y] : "
read -r SSL_RESPONSE

echo "Changing to homeassistant user..."
sudo -u homeassistant -H /bin/bash << EOF
cd

if [ "$SSL_RESPONSE" == "y" ] || [ "$SSL_RESPONSE" == "Y" ]; then
  git clone https://github.com/lukas2511/dehydrated.git
  cd dehydrated  || exit
  echo $domain".duckdns.org" | tee domains.txt
  echo "CHALLENGETYPE='dns-01'" | tee -a config
  echo "HOOK='./hook.sh'" | tee -a config
  curl -so ./hook.sh https://raw.githubusercontent.com/home-assistant/hassbian-scripts/dev/package/opt/hassbian/suites/files/ssl_hook.sh
  sed -i 's/myhome/'$domain'/g' ./hook.sh
  sed -i 's/your-duckdns-token/'$token'/g' ./hook.sh
  chmod 755 hook.sh
  ./dehydrated --register  --accept-terms
  ./dehydrated -c
fi

echo "Creating duckdns folder..."
cd /home/homeassistant || exit
mkdir duckdns
cd duckdns || exit

echo "Creating a script file to be used by cron."
echo "echo url='https://www.duckdns.org/update?domains=$domain&token=$token&ip=' | curl -k -o ~/duckdns/duck.log -K -" > duck.sh

echo "Setting premissions..."
chmod 700 duck.sh

echo "Creating cron job..."
(crontab -l ; echo "*/5 * * * * /home/homeassistant/duckdns/duck.sh >/dev/null 2>&1")| crontab -

EOF

if [ "$SSL_RESPONSE" == "y" ] || [ "$SSL_RESPONSE" == "Y" ]; then
  cp /opt/hassbian/suites/files/dehydrated_cron /etc/cron.daily/dehydrated
  chmod +x /etc/cron.daily/dehydrated
fi

echo "Restarting cron service..."
sudo systemctl restart cron.service

echo "Checking the installation..."
if [ "$SSL_RESPONSE" == "y" ] || [ "$SSL_RESPONSE" == "Y" ]; then
  certvalidation=$(find /home/homeassistant/dehydrated/certs/"$domain".duckdns.org/ -maxdepth 1 -type f | sort | grep privkey)
else
  certvalidation="ok"
fi
if [ ! -f /home/homeassistant/duckdns/duck.sh ]; then
  dnsvalidation=""
else
  dnsvalidation="ok"
fi

if [ ! -z "${certvalidation}" ] && [ ! -z "${dnsvalidation}" ]; then
  echo
  echo -e "\\e[32mInstallation done..\\e[0m"
  echo
  if [ "$SSL_RESPONSE" == "y" ] || [ "$SSL_RESPONSE" == "Y" ]; then
  echo "Remember to update your configuration.yaml to take advantage of SSL!"
  echo "Documentation for this can be found here <https://home-assistant.io/components/http/>."
  echo
  fi
else
  echo
  echo -e "\\e[31mInstallation failed..."
  echo
  return 1
fi
return 0
}

function duckdns-remove-package {
  echo "Removing certificates if installed."
  rm -R /home/homeassistant/dehydrated >/dev/null 2>&1

  echo "Removing cron jobs"
  rm /etc/cron.daily/dehydrated >/dev/null 2>&1
  crontab -u homeassistant -l | grep -v 'duck.sh'  | crontab -u homeassistant -

  echo
  echo -e "\\e[32mRemoval done..\\e[0m"
  echo
  return 0
}

[[ "$_" == "$0" ]] && echo "hassbian-config helper script; do not run directly, use hassbian-config instead"
