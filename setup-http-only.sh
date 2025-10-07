#!/bin/bash

# Простая настройка HTTP без SSL для начала
# Использование: ./setup-http-only.sh

DOMAIN="meddoors.dorren.ru"

echo "🌐 Настройка HTTP версии сайта (без SSL)"
echo "========================================"

# Проверка sudo прав
echo "Введите пароль sudo:"
sudo -v

# Проверка и установка nginx
echo "📦 Проверка nginx..."
if ! command -v nginx &> /dev/null; then
    echo "Установка nginx..."
    sudo apt update -qq
    sudo apt install -y nginx -qq
else
    echo "✅ Nginx уже установлен"
    sudo systemctl stop nginx 2>/dev/null || echo "nginx не запущен"
fi

# Создание директорий
echo "📁 Создание директорий..."
sudo mkdir -p /etc/nginx/sites-available
sudo mkdir -p /etc/nginx/sites-enabled
sudo mkdir -p /var/www/medical-doors/dist

# Очистка старых конфигураций
echo "🗑️ Очистка конфигураций..."
sudo rm -f /etc/nginx/sites-available/$DOMAIN
sudo rm -f /etc/nginx/sites-enabled/$DOMAIN
sudo rm -f /etc/nginx/sites-enabled/default

# Создание простой HTTP конфигурации
echo "⚙️ Создание HTTP конфигурации..."
sudo tee /etc/nginx/sites-available/$DOMAIN > /dev/null << 'EOF'
server {
    listen 80;
    server_name meddoors.dorren.ru www.meddoors.dorren.ru;

    root /var/www/medical-doors/dist;
    index index.html;

    # Кеширование статических файлов
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
        try_files $uri =404;
    }

    # Обработка SPA
    location / {
        try_files $uri $uri/ /index.html;
    }

    # Логи
    access_log /var/log/nginx/meddoors_access.log;
    error_log /var/log/nginx/meddoors_error.log;
}
EOF

# Активация сайта
echo "🔗 Активация сайта..."
sudo ln -sf /etc/nginx/sites-available/$DOMAIN /etc/nginx/sites-enabled/

# Проверка и запуск
echo "🔍 Проверка конфигурации..."
sudo nginx -t

if [ $? -eq 0 ]; then
    echo "✅ Конфигурация корректна"

    echo "🚀 Запуск nginx..."
    sudo systemctl start nginx
    sudo systemctl enable nginx

    echo ""
    echo "🎉 HTTP САЙТ НАСТРОЕН!"
    echo "======================"
    echo "🌐 Сайт доступен по адресу: http://$DOMAIN"
    echo ""
    echo "📋 Следующие шаги:"
    echo "1. Откройте http://$DOMAIN в браузере"
    echo "2. Убедитесь, что сайт работает"
    echo "3. Затем настройте SSL сертификаты"
    echo ""
    echo "🔧 Для HTTPS выполните:"
    echo "sudo certbot --nginx -d $DOMAIN -d www.$DOMAIN"
else
    echo "❌ Ошибка в конфигурации"
    echo "Проверьте: sudo nginx -t"
fi