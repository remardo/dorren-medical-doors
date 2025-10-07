#!/bin/bash

# Быстрая настройка SSL для meddoors.dorren.ru
# Использование: ./quick-ssl.sh

DOMAIN="meddoors.dorren.ru"
SERVER_IP="89.23.98.187"

echo "🔒 Быстрая настройка SSL для $DOMAIN"
echo "===================================="

# Проверка доступности сайта
echo "🔍 Проверка HTTP сайта..."
if curl -I http://$DOMAIN 2>/dev/null | grep -q "200"; then
    echo "✅ HTTP сайт доступен"
else
    echo "❌ HTTP сайт недоступен"
    echo "Сначала настройте HTTP версию сайта"
    exit 1
fi

# Установка certbot
echo "📦 Установка certbot..."
sudo apt update -qq
sudo apt install -y certbot python3-certbot-nginx -qq

# Настройка firewall для HTTPS
echo "🔥 Настройка firewall..."
sudo ufw allow 443/tcp
sudo ufw allow 80/tcp

# Получение SSL сертификата
echo "🔐 Получение SSL сертификата..."
sudo certbot --nginx -d $DOMAIN -d www.$DOMAIN --non-interactive --agree-tos --register-unsafely-without-email

if [ $? -eq 0 ]; then
    echo "✅ SSL сертификат получен успешно!"

    # Проверка HTTPS
    echo "🌐 Проверка HTTPS..."
    if curl -I https://$DOMAIN 2>/dev/null | grep -q "200"; then
        echo "✅ HTTPS работает корректно"
    else
        echo "⚠️ Проверьте HTTPS: curl -I https://$DOMAIN"
    fi

    # Настройка автоматического обновления
    echo "🔄 Настройка автобновления..."
    sudo systemctl enable certbot.timer
    sudo systemctl start certbot.timer

    echo ""
    echo "🎉 SSL НАСТРОЕН!"
    echo "================"
    echo "🔒 https://$DOMAIN"
    echo "🔒 https://www.$DOMAIN"
    echo ""
    echo "📋 Сертификат истекает:"
    sudo certbot certificates | grep "Expiry Date"
    echo ""
    echo "🔧 Управление:"
    echo "sudo certbot certificates    # Проверка сертификатов"
    echo "sudo certbot renew          # Обновление сертификата"
    echo "sudo systemctl status certbot.timer  # Статус автобновления"
else
    echo "❌ Ошибка получения сертификата"
    echo ""
    echo "🔧 Возможные причины:"
    echo "1. Домен не указывает на сервер"
    echo "2. Порт 80 заблокирован"
    echo "3. DNS не настроен"
    echo ""
    echo "Проверьте:"
    echo "nslookup $DOMAIN"
    echo "ping $DOMAIN"
fi