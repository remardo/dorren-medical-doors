#!/bin/bash

# Скрипт исправления сервера - установка nginx и настройка
# Использование: curl -s https://example.com/server-fix.sh | bash

SERVER_IP="89.23.98.187"

echo "🔧 Исправление сервера медицинских дверей"
echo "=========================================="

# Проверка прав доступа
if [ "$EUID" -eq 0 ]; then
    echo "❌ Не запускайте от root пользователя"
    exit 1
fi

echo "📦 Шаг 1: Обновление системы..."
sudo apt update && sudo apt upgrade -y

echo "🔧 Шаг 2: Установка Nginx..."
sudo apt install -y nginx

echo "📁 Шаг 3: Создание директорий..."
sudo mkdir -p /var/www/medical-doors/dist
sudo mkdir -p /etc/nginx/sites-available
sudo mkdir -p /etc/nginx/sites-enabled

echo "⚙️ Шаг 4: Настройка Nginx..."
sudo tee /etc/nginx/sites-available/medical-doors > /dev/null << 'EOF'
server {
    listen 80;
    server_name _;
    root /var/www/medical-doors/dist;
    index index.html;

    # Оптимизация производительности
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_types text/plain text/css text/xml text/javascript application/javascript application/xml+rss application/json;

    # Кеширование статических файлов
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
        try_files $uri =404;
    }

    # Обработка SPA (React Router)
    location / {
        try_files $uri $uri/ /index.html;
    }

    # Безопасность
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;

    # Логи
    access_log /var/log/nginx/medical-doors_access.log;
    error_log /var/log/nginx/medical-doors_error.log;
}
EOF

echo "🔗 Шаг 5: Активация сайта..."
sudo rm -f /etc/nginx/sites-enabled/default
sudo ln -sf /etc/nginx/sites-available/medical-doors /etc/nginx/sites-enabled/

echo "🔍 Шаг 6: Проверка конфигурации..."
sudo nginx -t

echo "🚀 Шаг 7: Запуск Nginx..."
sudo systemctl start nginx
sudo systemctl enable nginx

echo "📋 Шаг 8: Проверка статуса..."
sudo systemctl status nginx --no-pager -l

echo ""
echo "✅ Сервер исправлен и настроен!"
echo "================================"
echo "🌐 Сайт должен быть доступен по адресу: http://$SERVER_IP"
echo ""
echo "📁 Проверьте файлы:"
ls -la /var/www/medical-doors/dist/
echo ""
echo "🔧 Если сайт не работает:"
echo "sudo tail -f /var/log/nginx/medical-doors_error.log"
echo "sudo systemctl restart nginx"