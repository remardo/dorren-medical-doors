#!/bin/bash

# Исправление конфигурации nginx для SSL сертификатов
# Использование: ./nginx-fix-ssl.sh

DOMAIN="meddoors.dorren.ru"
SERVER_IP="89.23.98.187"

echo "🔧 Исправление конфигурации nginx для SSL"
echo "=========================================="

# Остановка nginx для редактирования
echo "🛑 Остановка nginx..."
sudo systemctl stop nginx

# Создание правильной конфигурации
echo "⚙️ Создание конфигурации nginx..."
sudo tee /etc/nginx/sites-available/$DOMAIN > /dev/null << EOF
server {
    listen 80;
    server_name $DOMAIN www.$DOMAIN;
    return 301 https://\$server_name\$request_uri;
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
    ssl_prefer_server_ciphers off;
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 10m;

    # Безопасность
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;

    # Корневая директория
    root /var/www/medical-doors/dist;
    index index.html;

    # Gzip сжатие
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_types text/plain text/css text/xml text/javascript application/javascript application/xml+rss application/json;

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
EOF

# Удаление старой конфигурации
echo "🗑️ Удаление старой конфигурации..."
sudo rm -f /etc/nginx/sites-enabled/default
sudo rm -f /etc/nginx/sites-enabled/medical-doors

# Активация новой конфигурации
echo "🔗 Активация новой конфигурации..."
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

    # Установка сертификата вручную
    echo "🔐 Установка SSL сертификата..."
    sudo certbot install --cert-name $DOMAIN

    # Проверка HTTPS
    echo "🌐 Проверка HTTPS..."
    sleep 3
    if curl -I https://$DOMAIN 2>/dev/null | grep -q "200"; then
        echo "✅ HTTPS работает корректно!"
        echo "🌐 Сайт доступен по адресу: https://$DOMAIN"
    else
        echo "⚠️ Проверка HTTPS не удалась"
        echo "Попробуйте: curl -I https://$DOMAIN"
    fi

    echo ""
    echo "🎉 SSL НАСТРОЕН УСПЕШНО!"
    echo "========================"
    echo "🔒 https://$DOMAIN"
    echo "🔒 https://www.$DOMAIN"
    echo ""
    echo "📋 Сертификат истекает: $(sudo certbot certificates | grep 'Expiry Date' | head -1)"
    echo ""
    echo "🔧 Управление сертификатами:"
    echo "sudo certbot certificates                    # Проверка"
    echo "sudo certbot renew                          # Обновление"
    echo "sudo systemctl status certbot.timer         # Автообновление"
else
    echo "❌ Ошибка в конфигурации nginx"
    echo "Проверьте: sudo nginx -t"
fi