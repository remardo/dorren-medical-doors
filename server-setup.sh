#!/bin/bash

# Автоматическая настройка сервера для медицинских дверей
# Использование: curl -s https://raw.githubusercontent.com/.../server-setup.sh | bash

set -e

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

warning() {
    echo -e "${YELLOW}[WARNING] $1${NC}"
}

error() {
    echo -e "${RED}[ERROR] $1${NC}"
    exit 1
}

PROJECT_NAME="medical-doors"
SERVER_DIR="/var/www/$PROJECT_NAME"

log "🚀 Начинаем автоматическую настройку сервера..."

# Проверка прав доступа
if [ "$EUID" -eq 0 ]; then
    error "Не запускайте скрипт от root пользователя. Используйте sudo для отдельных команд."
fi

# Обновление системы
log "📦 Обновление системы..."
sudo apt update && sudo apt upgrade -y

# Установка необходимого ПО
log "🔧 Установка необходимого ПО..."
sudo apt install -y nginx curl wget git htop nano

# Установка Node.js (опционально, для будущего использования)
log "📦 Установка Node.js..."
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt-get install -y nodejs

# Создание директории сайта
log "📁 Создание директории сайта..."
sudo mkdir -p $SERVER_DIR/dist
sudo chown -R $USER:$USER $SERVER_DIR

# Создание примера index.html если файлов нет
if [ ! -f "$SERVER_DIR/dist/index.html" ]; then
    log "📄 Создание временного index.html..."
    sudo tee $SERVER_DIR/dist/index.html > /dev/null << 'EOF'
<!DOCTYPE html>
<html lang="ru">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Медицинские двери - Развертывание</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            text-align: center;
            padding: 50px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
        }
        .container {
            max-width: 600px;
            margin: 0 auto;
            background: rgba(255,255,255,0.1);
            padding: 40px;
            border-radius: 10px;
        }
        h1 { margin-bottom: 20px; }
        .status { margin: 20px 0; padding: 15px; background: rgba(0,255,0,0.2); border-radius: 5px; }
    </style>
</head>
<body>
    <div class="container">
        <h1>🚀 Медицинские двери</h1>
        <div class="status">
            <h3>✅ Сервер настроен успешно!</h3>
            <p>Теперь загрузите файлы сайта для завершения настройки.</p>
        </div>
        <p><strong>Следующий шаг:</strong> Запустите скрипт развертывания с локальной машины</p>
        <code>./auto-deploy.sh root@your-server-ip</code>
    </div>
</body>
</html>
EOF
fi

# Настройка Nginx
log "⚙️ Настройка Nginx..."
sudo tee /etc/nginx/sites-available/$PROJECT_NAME > /dev/null << NGINX_EOF
server {
    listen 80;
    server_name _;
    root $SERVER_DIR/dist;
    index index.html;

    # Оптимизация производительности
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_types text/plain text/css text/xml text/javascript application/javascript application/xml+rss application/json;

    # Кеширование статических файлов
    location ~* \\.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
        try_files \$uri =404;
    }

    # Обработка SPA (React Router)
    location / {
        try_files \$uri \$uri/ /index.html;
    }

    # Безопасность
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;

    # Логи
    access_log /var/log/nginx/${PROJECT_NAME}_access.log;
    error_log /var/log/nginx/${PROJECT_NAME}_error.log;
}
NGINX_EOF

# Активация сайта
log "🔗 Активация сайта..."
sudo rm -f /etc/nginx/sites-enabled/default
sudo ln -sf /etc/nginx/sites-available/$PROJECT_NAME /etc/nginx/sites-enabled/

# Настройка прав доступа
sudo chown -R www-data:www-data $SERVER_DIR/dist
sudo chmod -R 755 $SERVER_DIR/dist
find $SERVER_DIR/dist -type f -exec chmod 644 {} \;

# Проверка конфигурации и перезапуск
log "🔍 Проверка конфигурации..."
sudo nginx -t

log "🔄 Перезапуск Nginx..."
sudo systemctl reload nginx
sudo systemctl enable nginx

# Финальная проверка
log "✅ Проверка статуса сервисов..."
sudo systemctl status nginx --no-pager -l

# Получение IP адреса сервера
SERVER_IP=$(curl -s ifconfig.me || hostname -I | awk '{print $1}')

log "🎉 Настройка сервера завершена успешно!"
echo
echo "=================================================="
echo "🌐 Сервер доступен по адресу: http://$SERVER_IP"
echo "📁 Директория сайта: $SERVER_DIR/dist"
echo "📊 Логи доступа: /var/log/nginx/${PROJECT_NAME}_access.log"
echo "❌ Логи ошибок: /var/log/nginx/${PROJECT_NAME}_error.log"
echo "=================================================="
echo
echo "📋 Следующие шаги:"
echo "1. Загрузите файлы сайта: ./auto-deploy.sh root@$SERVER_IP"
echo "2. Или загрузите файлы вручную в $SERVER_DIR/dist/"
echo "3. Откройте http://$SERVER_IP в браузере"
echo
echo "🔧 Полезные команды:"
echo "sudo systemctl status nginx                    # Статус сервера"
echo "sudo systemctl restart nginx                   # Перезапуск сервера"
echo "sudo tail -f /var/log/nginx/${PROJECT_NAME}_access.log  # Просмотр логов"
echo "sudo nano /etc/nginx/sites-available/$PROJECT_NAME      # Редактирование конфигурации"