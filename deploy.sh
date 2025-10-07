#!/bin/bash

# Скрипт для развертывания на VPS
# Использование: ./deploy.sh user@your-vps-ip /path/to/server/dir

SERVER_USER=$1
SERVER_PATH=$2

if [ -z "$SERVER_USER" ] || [ -z "$SERVER_PATH" ]; then
    echo "Использование: ./deploy.sh user@your-vps-ip /path/to/server/dir"
    echo "Пример: ./deploy.sh root@192.168.1.100 /var/www/medical-doors"
    exit 1
fi

echo "🚀 Начинаем развертывание на $SERVER_USER..."

# Сборка проекта
echo "📦 Сборка production версии..."
npm run build

if [ $? -ne 0 ]; then
    echo "❌ Ошибка сборки проекта"
    exit 1
fi

echo "✅ Сборка завершена успешно"

# Создание архива
echo "📁 Создание архива..."
tar -czf dist.tar.gz -C dist .

# Загрузка на сервер
echo "📤 Загрузка файлов на сервер..."
scp dist.tar.gz $SERVER_USER:$SERVER_PATH/

# Распаковка на сервере
echo "📋 Распаковка файлов на сервере..."
ssh $SERVER_USER "cd $SERVER_PATH && \
    sudo mkdir -p dist && \
    tar -xzf dist.tar.gz -C dist && \
    rm dist.tar.gz && \
    sudo chown -R www-data:www-data dist && \
    sudo chmod -R 755 dist && \
    sudo systemctl reload nginx"

# Очистка локального архива
rm dist.tar.gz

echo "✅ Развертывание завершено успешно!"
echo "🌐 Сайт должен быть доступен по адресу: http://your-domain.com"