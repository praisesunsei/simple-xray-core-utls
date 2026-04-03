#!/bin/bash
echo "🐉 Hysteria2 с QR.png файлом"

# Зависимости (если нет)
apt install -y qrencode

IP=$(curl -4 -s icanhazip.com)
PASS=$(grep 'password:' /etc/hysteria/server.yaml | awk '{print $2}')
OBFS=$(grep -A5 'obfs:' /etc/hysteria/server.yaml | grep password | awk '{print $2}')

# 🎨 QR как PNG файл в текущей папке!
LINK="hysteria2://$PASS@$IP:443?sni=www.youtube.com&obfs=salamander&obfs-password=$OBFS#Hysteria2-$IP"
qrencode -o hysteria-qr.png -s 10 -l H "$LINK"

# + Текстовый вывод
echo "📱 Ссылка:"
echo "$LINK"
echo ""
echo "🖼 QR сохранён: hysteria-qr.png (10x10 пикселей, High error correction)"
echo "📱 Скачай: scp user@VPS:~hysteria-qr.png ."
ls -la hysteria-qr.png
