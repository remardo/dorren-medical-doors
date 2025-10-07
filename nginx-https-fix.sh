#!/bin/bash

# Полное исправление nginx конфигурации для HTTPS
# Выполните на сервере: curl -s https://example.com/nginx-https-fix.sh | bash

DOMAIN="meddoors.dorren.ru"

echo "🔧 Полное исправление nginx для HTTPS"
echo "====================================="

# Запрос пароля sudo в начале
echo "Введите пароль sudo для продолжения:"
sudo -v

# Проверка sudo прав
if [ $? -ne 0 ]; then
    echo "❌ Требуются права sudo"
    echo "Выполните: sudo -v"
    exit 1
fi

# Проверка и установка nginx
echo "📦 Проверка и установка nginx..."
if ! command -v nginx &> /dev/null; then
    echo "Установка nginx..."
    sudo apt update -qq
    sudo apt install -y nginx -qq
else
    echo "✅ Nginx уже установлен"
    sudo systemctl stop nginx 2>/dev/null || echo "nginx не запущен"
fi

# Создание необходимых директорий
echo "📁 Создание директорий..."
sudo mkdir -p /etc/nginx/sites-available
sudo mkdir -p /etc/nginx/sites-enabled
sudo mkdir -p /var/www/medical-doors/dist

# Удаление старых конфигураций
echo "🗑️ Очистка старых конфигураций..."
sudo rm -f /etc/nginx/sites-available/meddoors.dorren.ru
sudo rm -f /etc/nginx/sites-enabled/meddoors.dorren.ru
sudo rm -f /etc/nginx/sites-enabled/default

# Создание новой конфигурации (сначала HTTP, затем добавим HTTPS)
echo "⚙️ Создание HTTP конфигурации..."
sudo tee /etc/nginx/sites-available/$DOMAIN > /dev/null << EOF
server {
    listen 80;
    server_name $DOMAIN www.$DOMAIN;

    # Корневая директория сайта
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

    # Получение SSL сертификата
    echo "🔐 Получение SSL сертификата..."
    sudo certbot --nginx -d $DOMAIN -d www.$DOMAIN --non-interactive --agree-tos --register-unsafely-without-email

    if [ $? -eq 0 ]; then
        echo "✅ SSL сертификат получен успешно!"

        # Финальная проверка
        echo "🌐 Финальная проверка..."
        sleep 3

        echo "HTTP ответ:"
        curl -I http://$DOMAIN 2>/dev/null | head -3 || echo "❌ HTTP не отвечает"

        echo "HTTPS ответ:"
        curl -I https://$DOMAIN 2>/dev/null | head -3 || echo "❌ HTTPS не отвечает"

        echo ""
        echo "🎉 SSL НАСТРОЕН УСПЕШНО!"
        echo "========================"
        echo "🔒 Сайт доступен по адресам:"
        echo "   https://$DOMAIN"
        echo "   https://www.$DOMAIN"
        echo ""
        echo "📋 Сертификат истекает:"
        sudo certbot certificates | grep 'Expiry Date' | head -1
    else
        echo "⚠️ Не удалось получить SSL сертификат автоматически"
        echo "Сайт работает по HTTP: http://$DOMAIN"
        echo ""
        echo "Для получения SSL сертификата вручную выполните:"
        echo "sudo certbot --nginx -d $DOMAIN -d www.$DOMAIN"
    fi
else
    echo "❌ Ошибка в конфигурации nginx"
    echo "Проверьте синтаксис: sudo nginx -t"
fi