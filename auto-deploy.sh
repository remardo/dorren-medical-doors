#!/bin/bash

# Автоматический скрипт развертывания медицинских дверей на VPS
# Использование: ./auto-deploy.sh [server-user@server-ip]

set -e  # Прерывать выполнение при ошибке

SERVER_USER=${1:-root@your-vps-ip}
PROJECT_NAME="medical-doors"
SERVER_DIR="/var/www/$PROJECT_NAME"
LOCAL_DIST="./dist"

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Функция логирования
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

# Определение окружения
detect_environment() {
    if [ -f "/etc/os-release" ] && grep -q "Ubuntu\|Debian" /etc/os-release 2>/dev/null; then
        if [ -d "/var/www" ] && [ -w "/var/www" ]; then
            echo "server"
        else
            echo "local"
        fi
    else
        echo "local"
    fi
}

ENVIRONMENT=$(detect_environment)
log "Определено окружение: $ENVIRONMENT"

if [ "$ENVIRONMENT" = "server" ]; then
    log "Запуск серверной настройки..."
    bash server-setup.sh
    exit 0
fi

# Локальное окружение - начинаем развертывание
log "🚀 Начинаем автоматическое развертывание на $SERVER_USER"

# Проверка наличия необходимых файлов
if [ ! -d "$LOCAL_DIST" ]; then
    log "Сборка проекта..."
    npm run build
    if [ $? -ne 0 ]; then
        error "Ошибка сборки проекта"
    fi
fi

# Проверка наличия сервера
log "Проверка доступности сервера..."
if ! ping -c 3 $(echo $SERVER_USER | cut -d'@' -f2) >/dev/null 2>&1; then
    error "Сервер $SERVER_USER недоступен"
fi

# Создание архива для передачи
log "📦 Подготовка файлов для передачи..."
ARCHIVE_NAME="${PROJECT_NAME}_$(date +%Y%m%d_%H%M%S).tar.gz"
tar -czf "$ARCHIVE_NAME" -C "$LOCAL_DIST" .

# Передача и настройка на сервере
log "📤 Передача файлов на сервер..."
scp "$ARCHIVE_NAME" "$SERVER_USER:/tmp/"

# Выполнение серверной настройки
log "⚙️ Выполнение настройки сервера..."
ssh "$SERVER_USER" "bash -s" << EOF
set -e

PROJECT_NAME="$PROJECT_NAME"
SERVER_DIR="$SERVER_DIR"
ARCHIVE_NAME="$ARCHIVE_NAME"

# Установка необходимого ПО
log "Установка необходимого ПО..."
sudo apt update
sudo apt install -y nginx curl wget

# Создание директории сайта
sudo mkdir -p \$SERVER_DIR/dist
sudo chown -R \$USER:\$USER \$SERVER_DIR

# Распаковка файлов
cd /tmp
tar -xzf \$ARCHIVE_NAME -C \$SERVER_DIR/dist/
rm \$ARCHIVE_NAME

# Настройка прав доступа
sudo chown -R www-data:www-data \$SERVER_DIR/dist
sudo chmod -R 755 \$SERVER_DIR/dist
find \$SERVER_DIR/dist -type f -exec chmod 644 {} \;

# Настройка Nginx
log "Настройка Nginx..."
sudo tee /etc/nginx/sites-available/\$PROJECT_NAME > /dev/null << NGINX_EOF
server {
    listen 80;
    server_name _;
    root \$SERVER_DIR/dist;
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
    access_log /var/log/nginx/\${PROJECT_NAME}_access.log;
    error_log /var/log/nginx/\${PROJECT_NAME}_error.log;
}
NGINX_EOF

# Активация сайта
sudo rm -f /etc/nginx/sites-enabled/default
sudo ln -sf /etc/nginx/sites-available/\$PROJECT_NAME /etc/nginx/sites-enabled/

# Проверка конфигурации и перезапуск
sudo nginx -t && sudo systemctl reload nginx

log "✅ Сервер настроен успешно!"
log "🌐 Сайт доступен по адресу: http://\$(curl -s ifconfig.me)"
EOF

# Очистка локального архива
rm "$ARCHIVE_NAME"

log "🎉 Развертывание завершено успешно!"
log "📋 Проверьте сайт в браузере: http://$(curl -s ifconfig.me 2>/dev/null || echo 'your-server-ip')"
log "📊 Для мониторинга: ssh $SERVER_USER 'sudo tail -f /var/log/nginx/${PROJECT_NAME}_access.log'"