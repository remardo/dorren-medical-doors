#!/bin/bash

# Ручная установка SSL сертификата для meddoors.dorren.ru
# Использование: ./manual-ssl-fix.sh

DOMAIN="meddoors.dorren.ru"

echo "🔧 Ручная установка SSL сертификата"
echo "==================================="

# Проверка sudo прав
sudo -v

# Шаг 1: Проверка существования сертификата
echo "🔍 Шаг 1: Проверка сертификата..."
if [ -f "/etc/letsencrypt/live/$DOMAIN/fullchain.pem" ]; then
    echo "✅ Сертификат найден"

    # Шаг 2: Создание правильной конфигурации
    echo "⚙️ Шаг 2: Создание конфигурации nginx..."
    sudo tee /etc/nginx/sites-available/$DOMAIN > /dev/null << EOF
server {
    listen 80;
    server_name $DOMAIN www.$DOMAIN;

    # Корневая директория сайта
    root /var/www/medical-doors/dist;
    index index.html;

    # Кеширование статических файлов
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
        try_files \$uri =404;
    }

    # Обработка SPA
    location / {
        try_files \$uri \$uri/ /index.html;
    }

    # Логи
    access_log /var/log/nginx/${DOMAIN}_access.log;
    error_log /var/log/nginx/${DOMAIN}_error.log;
}

server {
    listen 443 ssl http2;
    server_name $DOMAIN www.$DOMAIN;

    # SSL сертификаты
    ssl_certificate /etc/letsencrypt/live/$DOMAIN/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/$DOMAIN/privkey.pem;

    # Оптимизация SSL
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-RSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384;

    # Корневая директория сайта
    root /var/www/medical-doors/dist;
    index index.html;

    # Кеширование статических файлов
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
        try_files \$uri =404;
    }

    # Обработка SPA
    location / {
        try_files \$uri \$uri/ /index.html;
    }

    # Логи
    access_log /var/log/nginx/${DOMAIN}_ssl_access.log;
    error_log /var/log/nginx/${DOMAIN}_ssl_error.log;
}
EOF

    # Шаг 3: Активация конфигурации
    echo "🔗 Шаг 3: Активация конфигурации..."
    sudo rm -f /etc/nginx/sites-enabled/$DOMAIN
    sudo ln -sf /etc/nginx/sites-available/$DOMAIN /etc/nginx/sites-enabled/

    # Шаг 4: Проверка конфигурации
    echo "🔍 Шаг 4: Проверка конфигурации..."
    sudo nginx -t

    if [ $? -eq 0 ]; then
        echo "✅ Конфигурация корректна"

        # Шаг 5: Запуск nginx
        echo "🚀 Шаг 5: Запуск nginx..."
        sudo systemctl start nginx

        # Шаг 6: Финальная проверка
        echo "🌐 Шаг 6: Проверка HTTP и HTTPS..."
        sleep 3

        echo "HTTP ответ:"
        curl -I http://$DOMAIN 2>/dev/null | head -3 || echo "❌ HTTP не отвечает"

        echo "HTTPS ответ:"
        curl -I https://$DOMAIN 2>/dev/null | head -3 || echo "❌ HTTPS не отвечает"

        echo ""
        echo "🎉 SSL УСПЕШНО НАСТРОЕН!"
        echo "========================"
        echo "🔒 Сайт доступен по адресам:"
        echo "   http://$DOMAIN"
        echo "   https://$DOMAIN"
        echo ""
        echo "📋 Сертификат активен:"
        sudo certbot certificates | grep -A 4 "Certificate Name"
    else
        echo "❌ Ошибка в конфигурации"
        echo "Проверьте: sudo nginx -t"
    fi
else
    echo "❌ Сертификат не найден в /etc/letsencrypt/live/$DOMAIN/"
    echo ""
    echo "Сначала получите сертификат:"
    echo "sudo certbot certonly --standalone -d $DOMAIN -d www.$DOMAIN"
    echo ""
    echo "Затем запустите этот скрипт снова"
fi