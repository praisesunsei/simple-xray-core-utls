#!/bin/bash
echo "🚀 Устанавливаем Hysteria2 (анти-РКН 2026)"
sleep 3

# Обновление + зависимости
apt update && apt install -y golang-go qrencode curl jq nginx iptables-persistent

# BBR (ускорение)
echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf
echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf
sysctl -p

# Hysteria2 (последняя версия)
go install github.com/apernet/hysteria/cmd/hysteria@latest

# Nginx fallback (127.0.0.1:80)
cat > /etc/nginx/sites-enabled/fallback << EOF
server {
  listen 80;
  location / { return 200 'OK\\n'; }
}
EOF
systemctl restart nginx

# Генерация пароля
PASSWORD=$(openssl rand -base64 16 | tr -d "=+/" | cut -c1-16)

# Сервер Hysteria2 config
cat > /usr/local/etc/hysteria/server.yaml << EOF
listen: :443

# TLS (самоподписанный)
tls:
  cert: /etc/ssl/certs/ssl-cert-snakeoil.pem
  key: /etc/ssl/private/ssl-cert-snakeoil.key

# Авторизация
auth:
  type: password
  password: $PASSWORD

# Маскировка под YouTube
masquerade:
  type: proxy
  proxy:
    url: https://www.youtube.com
    rewriteHost: true

# QUIC параметры (анти-DPI)
quic:
  initStreamReceiveWindow: 8388608
  maxStreamReceiveWindow: 8388608
  initConnReceiveWindow: 20971520
  maxConnReceiveWindow: 20971520

# Obfuscation (саламандр)
obfs:
  type: salamander
  password: $(openssl rand -base64 32)

# Маскировка метаданных
metadata:
  http:
    path: /
    host: www.youtube.com
EOF

# Запуск Hysteria2
systemctl stop xray 2>/dev/null || true
nohup hysteria server -c /usr/local/etc/hysteria/server.yaml > /var/log/hysteria.log 2>&1 &
sleep 3

# Пользовательские команды
cat > /usr/local/bin/hysteria-info << EOF
#!/bin/bash
IP=\$(curl -4 -s icanhazip.com)
echo "🌐 IP: \$IP:443"
echo "🔑 Password: $PASSWORD"
echo "📱 Клиент: hysteria2://$PASSWORD@\$IP:443?sni=www.youtube.com"
echo "\$ echo hysteria2://$PASSWORD@\$IP:443?sni=www.youtube.com | qrencode -t ansiutf8"
EOF
chmod +x /usr/local/bin/hysteria-info

# Help файл
cat > ~/hysteria-help << EOF
🔥 Hysteria2 запущен на порту 443

Команды:
hysteria-info  — IP, пароль, QR-код

Конфиг: /usr/local/etc/hysteria/server.yaml
Логи:   /var/log/hysteria.log

Перезапуск: systemctl restart hysteria-server

Клиент sing-box:
{
  "type": "hysteria2",
  "server": "\$IP",
  "server_port": 443,
  "password": "$PASSWORD",
  "tls": {"sni": "www.youtube.com"}
}
EOF

# Автозапуск systemd
cat > /etc/systemd/system/hysteria-server.service << EOF
[Unit]
Description=Hysteria2 Server
After=network.target nginx.service

[Service]
ExecStart=/usr/local/bin/hysteria server -c /usr/local/etc/hysteria/server.yaml
Restart=always
User=nobody

[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload
systemctl enable hysteria-server

echo "🎉 Hysteria2 установлен и запущен!"
hysteria-info
cat ~/hysteria-help
