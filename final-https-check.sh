#!/bin/bash

# Финальная проверка и исправление HTTPS для meddoors.dorren.ru
# Использование: ./final-https-check.sh

DOMAIN="meddoors.dorren.ru"

echo "🔍 Финальная проверка HTTPS для $DOMAIN"
echo "======================================="

# Проверка HTTP сайта
echo "🌐 Шаг 1: Проверка HTTP сайта..."
HTTP_STATUS=$(curl -I http://$DOMAIN 2>/dev/null | head -1 | cut -d' ' -f2)

if [ "$HTTP_STATUS" = "200" ]; then
    echo "✅ HTTP сайт работает"
else
    echo "❌ HTTP сайт не отвечает (статус: $HTTP_STATUS)"
    echo "Проверьте файлы сайта в /var/www/medical-doors/dist/"
    exit 1
fi

# Проверка файлов сайта
echo "📁 Шаг 2: Проверка файлов сайта..."
if [ -f "/var/www/medical-doors/dist/index.html" ]; then
    echo "✅ Файлы сайта найдены"
    ls -la /var/www/medical-doors/dist/ | head -5
else
    echo "❌ Файлы сайта не найдены в /var/www/medical-doors/dist/"
    echo "Загрузите файлы сайта сначала"
    exit 1
fi

# Проверка SSL сертификата
echo "🔐 Шаг 3: Проверка SSL сертификата..."
if [ -f "/etc/letsencrypt/live/$DOMAIN/fullchain.pem" ]; then
    echo "✅ SSL сертификат найден"
    sudo certbot certificates | grep -A 3 "Certificate Name"
else
    echo "❌ SSL сертификат не найден"
    echo "Получите сертификат: sudo certbot --nginx -d $DOMAIN"
    exit 1
fi

# Проверка nginx конфигурации
echo "⚙️ Шаг 4: Проверка nginx конфигурации..."
sudo nginx -t

if [ $? -eq 0 ]; then
    echo "✅ Конфигурация nginx корректна"

    # Перезапуск nginx
    echo "🔄 Перезапуск nginx..."
    sudo systemctl reload nginx

    # Финальная проверка
    echo "🌐 Шаг 5: Финальная проверка..."
    sleep 3

    echo "=== РЕЗУЛЬТАТЫ ПРОВЕРКИ ==="
    echo "HTTP ответ:"
    curl -I http://$DOMAIN 2>/dev/null | head -3

    echo ""
    echo "HTTPS ответ:"
    curl -I https://$DOMAIN 2>/dev/null | head -3

    echo ""
    echo "=== ДИАГНОСТИКА ==="
    echo "Статус nginx:"
    sudo systemctl status nginx --no-pager -l | grep -E "(Active|Loaded|Memory)"

    echo ""
    echo "Логи ошибок nginx:"
    sudo tail -3 /var/log/nginx/${DOMAIN}_error.log 2>/dev/null || echo "Лог ошибок пуст"

    echo ""
    echo "Логи доступа nginx:"
    sudo tail -2 /var/log/nginx/${DOMAIN}_access.log 2>/dev/null || echo "Лог доступа пуст"

    echo ""
    echo "=== РЕКОМЕНДАЦИИ ==="
    if curl -I https://$DOMAIN 2>/dev/null | grep -q "200"; then
        echo "🎉 HTTPS работает корректно!"
        echo "🌐 Сайт доступен по адресу: https://$DOMAIN"
    else
        echo "⚠️ HTTPS не отвечает"
        echo "Проверьте:"
        echo "1. Файлы сайта в /var/www/medical-doors/dist/"
        echo "2. Конфигурацию nginx: sudo nano /etc/nginx/sites-available/$DOMAIN"
        echo "3. Логи ошибок: sudo tail -f /var/log/nginx/${DOMAIN}_error.log"
        echo "4. Статус nginx: sudo systemctl status nginx"
    fi
else
    echo "❌ Ошибка в конфигурации nginx"
    echo "Проверьте: sudo nginx -t"
fi