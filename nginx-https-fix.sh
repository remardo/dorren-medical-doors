#!/bin/bash

# Полное исправление nginx конфигурации для HTTPS
# Выполните на сервере: curl -s https://example.com/nginx-https-fix.sh | bash

DOMAIN="meddoors.dorren.ru"

echo "🔧 Полное исправление nginx для HTTPS"
echo "====================================="

# Остановка nginx
echo "🛑 Остановка nginx..."
sudo systemctl stop nginx

# Удаление старых конфигураций
echo "🗑️ Очистка старых конфигураций..."
sudo rm -f /etc/nginx/sites-available/*
sudo rm -f /etc/nginx/sites-enabled/*

# Создание новой конфигурации
echo "⚙️ Создание HTTPS конфигурации..."
sudo tee /etc/nginx/sites-available/$DOMAIN > /dev/null << EOF
server {
    listen 80;
    server_name $DOMAIN www.$DOMAIN;
    return 301 https://\$server_name\$request_uri;
}

server {
    listen 443 ssl http2;
    server_name $DOMAIN www.$DOMAIN;

    # SSL сертификаты от Let's Encrypt
    ssl_certificate /etc/letsencrypt/live/$DOMAIN/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/$DOMAIN/privkey.pem;

    # Оптимизация SSL
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-RSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-AES128-SHA256:ECDHE-RSA-AES256-SHA384;
    ssl_prefer_server_ciphers off;

    # SSL сессии для производительности
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 10m;

    # Заголовки безопасности
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains; preload" always;
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;

    # Корневая директория сайта
    root /var/www/medical-doors/dist;
    index index.html;

    # Gzip сжатие
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_proxied any;
    gzip_comp_level 6;
    gzip_types
        text/plain
        text/css
        text/xml
        text/javascript
        application/javascript
        application/xml+rss
        application/json;

    # Кеширование статических файлов на год
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
        try_files \$uri =404;
    }

    # Обработка SPA (React Router) - все запросы на index.html
    location / {
        try_files \$uri \$uri/ /index.html;
    }

    # Логи
    access_log /var/log/nginx/${DOMAIN}_access.log;
    error_log /var/log/nginx/${DOMAIN}_error.log;

    # Обработка ошибок
    error_page 404 /index.html;
    error_page 500 502 503 504 /50x.html;
}
EOF

# Активация сайта
echo "🔗 Активация сайта..."
sudo ln -sf /etc/nginx/sites-available/$DOMAIN /etc/nginx/sites-enabled/

# Проверка конфигурации
echo "🔍 Проверка конфигурации..."
sudo nginx -t

if [ $? -eq 0 ]; then
    echo "✅ Конфигурация корректна"

    # Запуск nginx
    echo "🚀 Запуск nginx..."
    sudo systemctl start nginx
    sudo systemctl enable nginx

    # Установка сертификата
    echo "🔐 Установка SSL сертификата..."
    sudo certbot install --cert-name $DOMAIN

    # Финальная проверка
    echo "🌐 Финальная проверка..."
    sleep 3

    echo "HTTP ответ:"
    curl -I http://$DOMAIN 2>/dev/null | head -3 || echo "❌ HTTP не отвечает"

    echo "HTTPS ответ:"
    curl -I https://$DOMAIN 2>/dev/null | head -3 || echo "❌ HTTPS не отвечает"

    echo ""
    echo "🎉 КОНФИГУРАЦИЯ ИСПРАВЛЕНА!"
    echo "==========================="
    echo "🌐 Сайт доступен по адресам:"
    echo "   🔒 https://$DOMAIN"
    echo "   🔒 https://www.$DOMAIN"
    echo ""
    echo "📋 Проверка сертификата:"
    sudo certbot certificates | grep -A 3 "Certificate Name"
    echo ""
    echo "🔧 Следующие шаги:"
    echo "1. Откройте https://$DOMAIN в браузере"
    echo "2. Убедитесь, что виден зеленый замочек 🔒"
    echo "3. Проверьте, что сайт работает корректно"
else
    echo "❌ Ошибка в конфигурации nginx"
    echo "Проверьте синтаксис: sudo nginx -t"
fi