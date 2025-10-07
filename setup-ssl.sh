#!/bin/bash

# Скрипт установки SSL сертификатов для сайта медицинских дверей
# Использование: ./setup-ssl.sh

DOMAIN="meddoors.dorren.ru"
SERVER_IP="89.23.98.187"

echo "🔒 Настройка SSL сертификатов для $DOMAIN"
echo "=========================================="

# Проверка доступности домена
echo "🔍 Шаг 1: Проверка доступности домена..."
if ping -c 3 $DOMAIN >/dev/null 2>&1; then
    echo "✅ Домен $DOMAIN доступен"
else
    echo "⚠️ Домен $DOMAIN недоступен по IP $SERVER_IP"
    echo "Убедитесь, что DNS настроен правильно"
fi

# Установка certbot
echo "📦 Шаг 2: Установка certbot..."
sudo apt update -qq
sudo apt install -y certbot python3-certbot-nginx -qq

# Получение SSL сертификата
echo "🔐 Шаг 3: Получение SSL сертификата..."
sudo certbot --nginx -d $DOMAIN -d www.$DOMAIN

if [ $? -eq 0 ]; then
    echo "✅ SSL сертификат успешно получен!"

    # Проверка сертификата
    echo "🔍 Шаг 4: Проверка сертификата..."
    sudo certbot certificates

    # Настройка автоматического обновления
    echo "🔄 Шаг 5: Настройка автоматического обновления..."
    sudo systemctl enable certbot.timer
    sudo systemctl start certbot.timer

    # Проверка HTTPS
    echo "🌐 Шаг 6: Проверка HTTPS работы..."
    echo "Проверьте сайт по адресам:"
    echo "🔒 https://$DOMAIN"
    echo "🔒 https://www.$DOMAIN"

    # Тест HTTPS ответа
    if curl -I https://$DOMAIN 2>/dev/null | grep -q "200"; then
        echo "✅ HTTPS работает корректно"
    else
        echo "⚠️ Проверьте HTTPS вручную: curl -I https://$DOMAIN"
    fi

    echo ""
    echo "🎉 SSL НАСТРОЕН УСПЕШНО!"
    echo "========================="
    echo "📋 Что было сделано:"
    echo "✅ Certbot установлен"
    echo "✅ SSL сертификат получен для $DOMAIN"
    echo "✅ Nginx настроен для HTTPS"
    echo "✅ Автоматическое обновление включено"
    echo ""
    echo "🔧 Управление сертификатами:"
    echo "sudo certbot certificates                    # Проверка сертификатов"
    echo "sudo certbot renew                          # Ручное обновление"
    echo "sudo certbot revoke --cert-name $DOMAIN     # Отзыв сертификата"
    echo "sudo systemctl status certbot.timer         # Статус автобновления"
    echo ""
    echo "📊 Мониторинг:"
    echo "sudo tail -f /var/log/letsencrypt/letsencrypt.log"
else
    echo "❌ Ошибка получения SSL сертификата"
    echo ""
    echo "🔧 Возможные решения:"
    echo "1. Проверьте, что домен указывает на правильный IP"
    echo "2. Убедитесь, что порт 80 открыт"
    echo "3. Проверьте DNS настройки домена"
    echo "4. Попробуйте получить сертификат вручную:"
    echo "   sudo certbot --nginx -d $DOMAIN"
fi