# Выдаёт ссылку + QR повторно
IP=$(curl -4 -s icanhazip.com)
PASS=$(grep 'password:' /etc/hysteria/server.yaml | awk '{print $2}')
OBFS=$(grep -A5 'obfs:' /etc/hysteria/server.yaml | grep password | awk '{print $2}')

echo "📱 Ссылка:"
echo "hysteria2://$PASS@$IP:443?sni=www.youtube.com&obfs=salamander&obfs-password=$OBFS#Hysteria2-$IP"
echo ""
echo "QR-код:"
echo "hysteria2://$PASS@$IP:443?sni=www.youtube.com&obfs=salamander&obfs-password=$OBFS#Hysteria2-$IP" | qrencode -t ansiutf8
