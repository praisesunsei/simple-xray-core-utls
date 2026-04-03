#!/bin/bash
echo "🗑 Удаляем Hysteria2 полностью..."

# Останавливаем процессы
pkill hysteria 2>/dev/null || true
pkill xray 2>/dev/null || true

# Удаляем systemd
systemctl stop hysteria-server 2>/dev/null || true
systemctl disable hysteria-server 2>/dev/null || true
rm -f /etc/systemd/system/hysteria-server.service
systemctl daemon-reload

# Удаляем файлы
rm -rf /etc/hysteria
rm -f /etc/hysteria/server.yaml
rm -f /usr/local/etc/hysteria
rm -f /var/log/hysteria.log
rm -f /usr/local/bin/hysteria-*
rm -f ~/hysteria-help

# Nginx cleanup
rm -f /etc/nginx/sites-enabled/fallback
ln -sf /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default
systemctl restart nginx

# Go cleanup
go clean -i -r github.com/apernet/hysteria/...

echo "✅ Hysteria2 удалена полностью!"
echo "🔄 VPS чистый — готов к новому скрипту!"
