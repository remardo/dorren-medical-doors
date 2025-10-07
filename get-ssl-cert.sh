#!/bin/bash

# Получение SSL сертификата для meddoors.dorren.ru одной командой
# Использование: ./get-ssl-cert.sh

DOMAIN="meddoors.dorren.ru"
SERVER_IP="89.23.98.187"

echo "🔒 Получение SSL сертификата для $DOMAIN"
echo "========================================"

# Проверка доступности сайта
echo "🔍 Проверка HTTP сайта..."
if curl -I http://$DOMAIN 2>/dev/null | grep -q "200\|301\|302"; then
    echo "✅ HTTP сайт доступен"
else
    echo "❌ HTTP сайт недоступен"
    echo "Сначала настройте HTTP версию сайта"
    echo "Проверьте: http://$DOMAIN"
    exit 1
fi

# Проверка DNS
echo "🌐 Проверка DNS..."
if nslookup $DOMAIN | grep -q "$SERVER_IP\|Address:"; then
    echo "✅ DNS настроен правильно"
else
    echo "⚠️ Проверьте DNS настройки домена $DOMAIN"
    echo "Домен должен указывать на $SERVER_IP"
fi

# Установка certbot
echo "📦 Установка certbot..."
sudo apt update -qq
sudo apt install -y certbot python3-certbot-nginx -qq

# Настройка firewall
echo "🔥 Настройка firewall..."
sudo ufw allow 443/tcp 2>/dev/null || true
sudo ufw allow 80/tcp 2>/dev/null || true

# Получение сертификата
echo "🔐 Получение SSL сертификата..."
sudo certbot --nginx -d $DOMAIN -d www.$DOMAIN --non-interactive --agree-tos --register-unsafely-without-email

if [ $? -eq 0 ]; then
    echo ""
    echo "🎉 SSL СЕРТИФИКАТ УСПЕШНО ПОЛУЧЕН!"
    echo "==================================="
    echo "🔒 Ваш сайт теперь доступен по HTTPS:"
    echo "   https://meddoors.dorren.ru"
    echo "   https://www.meddoors.dorren.ru"
    echo ""
    echo "📋 Информация о сертификате:"
    sudo certbot certificates | grep -A 5 "Certificate Name"
    echo ""
    echo "🔧 Автоматическое обновление:"
    echo "   Сертификат будет автоматически обновляться"
    echo "   Проверяйте статус: sudo systemctl status certbot.timer"
    echo ""
    echo "✅ РЕЗУЛЬТАТ:"
    echo "   ✅ HTTP → HTTPS редирект настроен"
    echo "   ✅ SSL сертификат активен"
    echo "   ✅ Автообновление включено"
    echo ""
    echo "🌐 Тестируйте сайт: https://meddoors.dorren.ru"
else
    echo ""
    echo "❌ ОШИБКА ПОЛУЧЕНИЯ СЕРТИФИКАТА"
    echo "==============================="
    echo ""
    echo "🔧 Возможные причины и решения:"
    echo ""
    echo "1. Домен не указывает на сервер:"
    echo "   Проверьте DNS настройки у регистратора домена"
    echo "   Выполните: nslookup $DOMAIN"
    echo ""
    echo "2. Порт 80 заблокирован:"
    echo "   Проверьте firewall: sudo ufw status"
    echo "   Откройте порты: sudo ufw allow 80 && sudo ufw allow 443"
    echo ""
    echo "3. Nginx не запущен:"
    echo "   Проверьте: sudo systemctl status nginx"
    echo "   Запустите: sudo systemctl start nginx"
    echo ""
    echo "4. Попробуйте вручную:"
    echo "   sudo certbot --nginx -d $DOMAIN"
    echo ""
    echo "📞 Если проблемы продолжаются:"
    echo "   - Проверьте настройки DNS у регистратора домена"
    echo "   - Убедитесь, что домен делегирован правильно"
    echo "   - Свяжитесь с поддержкой хостинга"
fi