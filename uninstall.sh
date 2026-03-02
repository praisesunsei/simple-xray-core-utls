#!/bin/bash
echo "🗑️  Удаляем Xray VLESS сервер..."
sleep 2

# Останавливаем сервис
systemctl stop xray || true
systemctl disable xray || true

# Удаляем файлы
rm -f /usr/local/etc/xray/config.json
rm -f /usr/local/etc/xray/.keys
rm -f /usr/local/bin/userlist /usr/local/bin/mainuser /usr/local/bin/newuser
rm -f /usr/local/bin/rmuser /usr/local/bin/sharelink
rm -f $HOME/help

# Удаляем Xray-core (через их скрипт)
bash -c "$(curl -4 -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ remove

# Удаляем зависимости
apt purge -y qrencode curl jq || true
apt autoremove -y

# Очищаем BBR (если добавляли)
sed -i '/bbr/d' /etc/sysctl.conf
sed -i '/fq/d' /etc/sysctl.conf
sysctl -p
