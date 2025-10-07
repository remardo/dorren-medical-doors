#!/bin/bash

# Супер простой скрипт развертывания на VPS
# Использование: ./deploy-to-vps.sh your-server-ip

SERVER_IP=$1

if [ -z "$SERVER_IP" ]; then
    echo "❌ Укажите IP адрес сервера"
    echo "Использование: ./deploy-to-vps.sh your-server-ip"
    echo "Пример: ./deploy-to-vps.sh 192.168.1.100"
    exit 1
fi

echo "🚀 Быстрое развертывание медицинских дверей на VPS"
echo "=================================================="
echo "📋 Сервер: $SERVER_IP"
echo ""

# Шаг 1: Определение платформы
PLATFORM=$(uname -s)
if [[ "$PLATFORM" == *"MINGW"* ]] || [[ "$PLATFORM" == *"MSYS"* ]]; then
    echo "📦 Обнаружена Windows платформа"
    echo "🔧 Рекомендация: Используйте Git Bash или WSL для сборки проекта"
    echo ""
fi

# Шаг 2: Сборка проекта
echo "📦 Шаг 1: Сборка проекта..."

# Проверка наличия dist папки
if [ ! -d "dist" ]; then
    echo "🔨 Сборка проекта с помощью npm run build..."

    # Попытка сборки
    npm run build

    BUILD_EXIT_CODE=$?

    # Небольшая пауза для файловой системы
    sleep 3

    if [ $BUILD_EXIT_CODE -ne 0 ]; then
        echo ""
        echo "❌ Ошибка сборки проекта!"
        echo ""
        echo "🔧 Используйте скрипт исправления:"
        echo "   ./fix-build.sh"
        echo ""
        echo "Или вручную:"
        echo "   rm -rf node_modules package-lock.json"
        echo "   npm install"
        echo "   npm run build"
        echo ""
        exit 1
    fi

    # Проверка существования файлов после сборки
    if [ -f "dist/index.html" ]; then
        echo "✅ Сборка успешна! Найден dist/index.html"
    else
        echo "⚠️ Сборка завершилась успешно, но файлы не найдены"
        echo "Проверьте содержимое папки dist:"
        ls -la dist/ 2>/dev/null || echo "Папка dist не существует"
        exit 1
    fi
else
    echo "✅ Папка dist найдена, пропускаем сборку"
    if [ -f "dist/index.html" ]; then
        echo "✅ Файлы сборки корректны"
    else
        echo "⚠️ Папка dist существует, но index.html не найден"
        echo "Пересоберите проект: npm run build"
        exit 1
    fi
fi

# Шаг 2: Проверка и подготовка файлов
echo "📤 Шаг 2: Проверка файлов и загрузка на сервер..."

# Финальная проверка файлов перед загрузкой
echo "🔍 Финальная проверка файлов..."

if [ ! -f "dist/index.html" ]; then
    echo "❌ Файл dist/index.html не найден!"
    echo "Сначала соберите проект: npm run build"
    exit 1
fi

if [ ! -d "dist/assets" ]; then
    echo "⚠️ Папка dist/assets не найдена"
    echo "Проверьте корректность сборки"
fi

echo "✅ Файлы готовы для загрузки:"
ls -la dist/ | head -10

# Шаг 3: Загрузка файлов
echo "📤 Шаг 3: Загрузка файлов на сервер..."

# Создание архива для надежной передачи
ARCHIVE_NAME="medical-doors-$(date +%Y%m%d-%H%M%S).tar.gz"
echo "📦 Создание архива: $ARCHIVE_NAME"
tar -czf "$ARCHIVE_NAME" -C dist .

# Загрузка с автоматическим подтверждением SSH ключа
echo "🔑 Добавление SSH ключа в known_hosts..."
mkdir -p ~/.ssh
ssh-keyscan -H $SERVER_IP >> ~/.ssh/known_hosts 2>/dev/null || true

echo "📤 Загрузка архива на сервер..."
scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "$ARCHIVE_NAME" root@$SERVER_IP:/tmp/

# Шаг 4: Настройка сервера
echo "⚙️ Шаг 4: Настройка сервера..."
ssh -T -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@$SERVER_IP << EOF
# Переменные для использования в скрипте
ARCHIVE_NAME="$ARCHIVE_NAME"

# Создание директории если не существует
sudo mkdir -p /var/www/medical-doors/dist

# Распаковка архива
echo "📦 Распаковка файлов на сервере..."
cd /tmp
sudo tar -xzf \$ARCHIVE_NAME -C /var/www/medical-doors/dist/
sudo rm \$ARCHIVE_NAME

# Настройка прав доступа
sudo chown -R www-data:www-data /var/www/medical-doors/dist
sudo chmod -R 755 /var/www/medical-doors/dist
EOF

# Настройка Nginx (если не настроен)
if [ ! -f "/etc/nginx/sites-available/medical-doors" ]; then
    sudo tee /etc/nginx/sites-available/medical-doors > /dev/null << 'NGINX_EOF'
server {
    listen 80;
    server_name _;
    root /var/www/medical-doors/dist;
    index index.html;

    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }

    location / {
        try_files $uri $uri/ /index.html;
    }
}
NGINX_EOF

    sudo ln -sf /etc/nginx/sites-available/medical-doors /etc/nginx/sites-enabled/
    sudo rm -f /etc/nginx/sites-enabled/default
fi

# Перезапуск Nginx
sudo nginx -t && sudo systemctl reload nginx

echo "✅ Сервер настроен и запущен!"
echo "🌐 Сайт доступен по адресу: http://$SERVER_IP"
EOF

# Очистка локального архива
echo "🧹 Очистка временных файлов..."
rm -f "$ARCHIVE_NAME"

echo ""
echo "🎉 Развертывание завершено!"
echo "=================================================="
echo "🌐 Сайт доступен по адресу: http://$SERVER_IP"
echo ""
echo "📋 Что было сделано:"
echo "✅ Проект собран (npm run build)"
echo "✅ Файлы загружены на сервер"
echo "✅ Nginx настроен и перезапущен"
echo "✅ Права доступа установлены"
echo ""
echo "🔧 Для проверки:"
echo "ssh root@$SERVER_IP 'sudo systemctl status nginx'"
echo "curl -I http://$SERVER_IP"
echo ""
echo "📊 Мониторинг:"
echo "ssh root@$SERVER_IP 'sudo tail -f /var/log/nginx/medical-doors_access.log'"