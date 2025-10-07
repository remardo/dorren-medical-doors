#!/bin/bash

# Исправление конфигурации nginx для работы с SSL сертификатами
# Использование: ./fix-nginx-config.sh

DOMAIN="meddoors.dorren.ru"

echo "🔧 Исправление конфигурации nginx для домена $DOMAIN"
echo "==================================================="

# Проверка sudo прав
sudo -v

# Остановка nginx
echo "🛑 Остановка nginx..."
sudo systemctl stop nginx

# Исправление конфигурации
echo "⚙️ Исправление конфигурации nginx..."
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

    # Обработка SPA (React Router)
    location / {
        try_files \$uri \$uri/ /index.html;
    }

    # Логи
    access_log /var/log/nginx/${DOMAIN}_access.log;
    error_log /var/log/nginx/${DOMAIN}_error.log;
}

# HTTPS сервер (автоматически настраивается certbot)
server {
    listen 443 ssl http2;
    server_name $DOMAIN www.$DOMAIN;

    # SSL сертификаты (управляются certbot)
    ssl_certificate /etc/letsencrypt/live/$DOMAIN/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/$DOMAIN/privkey.pem;

    # Оптимизация SSL
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-RSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384;
    ssl_prefer_server_ciphers off;

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

# Активация сайта
echo "🔗 Активация исправленной конфигурации..."
sudo rm -f /etc/nginx/sites-enabled/$DOMAIN
sudo ln -sf /etc/nginx/sites-available/$DOMAIN /etc/nginx/sites-enabled/

# Проверка конфигурации
echo "🔍 Проверка конфигурации..."
sudo nginx -t

if [ $? -eq 0 ]; then
    echo "✅ Конфигурация корректна"

    # Запуск nginx
    echo "🚀 Запуск nginx..."
    sudo systemctl start nginx

    # Установка сертификата
    echo "🔐 Установка SSL сертификата..."
    sudo certbot install --cert-name $DOMAIN

    # Финальная проверка
    echo "🌐 Проверка HTTP..."
    curl -I http://$DOMAIN 2>/dev/null | head -3 || echo "❌ HTTP не отвечает"

    echo "🌐 Проверка HTTPS..."
    curl -I https://$DOMAIN 2>/dev/null | head -3 || echo "❌ HTTPS не отвечает"

    echo ""
    echo "🎉 КОНФИГУРАЦИЯ ИСПРАВЛЕНА!"
    echo "==========================="
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