#!/bin/bash
echo "🐉 Hysteria2 СТЕЛС 2026 (полный скрипт)"
sleep 3

# Зависимости
apt update && apt install -y golang-go qrencode curl jq nginx iptables-persistent

# BBR
echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf
echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf
sysctl -p

# Hysteria2
go install github.com/apernet/hysteria/cmd/hysteria@latest

# Nginx fallback
cat > /etc/nginx/sites-enabled/fallback << EOF
server { listen 80; location / { return 200 'OK'; } }
EOF
systemctl restart nginx

# ОСТАНАВЛИВАЕМ старое
pkill xray hysteria 2>/dev/null || true

# ГЕНЕРИРУЕМ ключи
PASSWORD=$(openssl rand -base64 16 | tr -d "=+/" | cut -c1-16)
OBFS_PASS=$(openssl rand -base64 32 | tr -d "=+/" | head -c 32)
IP=$(curl -4 -s icanhazip.com)

# ПОЛНЫЙ STEALTH config
cat > /etc/hysteria/server.yaml << EOF
listen: :443

# TLS
tls:
  cert: /etc/ssl/certs/ssl-cert-snakeoil.pem
  key: /etc/ssl/private/ssl-cert-snakeoil.key

# SALAMANDER OBFUSCATION
obfs:
  type: salamander
  password: $OBFS_PASS

# Аутентификация
auth:
  type: password
  password: $PASSWORD

# YouTube маскировка
masquerade:
  type: proxy
  proxy:
    url: https://www.youtube.com
    rewriteHost: true

# Анти-DPI QUIC
quic:
  initStreamReceiveWindow: 8388608
  maxStreamReceiveWindow: 8388608
  initConnReceiveWindow: 20971520
  maxConnReceiveWindow: 20971520

# HTTP fingerprint
metadata:
  http:
    path: /
    host: www.youtube.com
EOF

# ЗАПУСК
nohup hysteria server -c /etc/hysteria/server.yaml > /var/log/hysteria.log 2>&1 &
sleep 5

# QR + ССЫЛКА
cat << EOF

🎉 HYSTERIA2 STEALTH УСТАНОВЛЕН!

🌐 IP: $IP:443
🔑 Password: $PASSWORD
🔒 Obfs: $OBFS_PASS

📱 Ссылка + QR:
EOF

echo "hysteria2://$PASSWORD@$IP:443?sni=www.youtube.com&obfs=salamander&obfs-password=$OBFS_PASS#Hysteria2-Stealth-$IP" | qrencode -t ansiutf8

echo ""
echo "📋 sing-box:"
echo "{"
echo "  \"type\": \"hysteria2\","
echo "  \"server\": \"$IP\","
echo "  \"server_port\": 443,"
echo "  \"password\": \"$PASSWORD\","
echo "  \"obfs\": {\"type\": \"salamander\", \"password\": \"$OBFS_PASS\"},"
echo "  \"tls\": {\"sni\": \"www.youtube.com\"}"
echo "}"

cat << EOF

🔄 Перезапуск: nohup hysteria server -c /etc/hysteria/server.yaml &
📊 Логи: tail -f /var/log/hysteria.log
EOF
