#!/bin/bash

# Скрипт для сборки и развертывания в два этапа
# Использование: ./build-and-deploy.sh your-server-ip

SERVER_IP=$1

if [ -z "$SERVER_IP" ]; then
    echo "❌ Укажите IP адрес сервера"
    echo "Использование: ./build-and-deploy.sh your-server-ip"
    exit 1
fi

echo "🚀 Двухэтапное развертывание медицинских дверей"
echo "=============================================="
echo "📋 Этап 1: Сборка проекта"
echo "📋 Этап 2: Загрузка на сервер: $SERVER_IP"
echo ""

# Этап 1: Сборка проекта
echo "📦 Этап 1: Сборка проекта..."
echo "Команда: npm run build"

npm run build

if [ $? -ne 0 ]; then
    echo ""
    echo "❌ Ошибка сборки!"
    echo "🔧 Исправьте проблему и попробуйте снова"
    exit 1
fi

echo ""
echo "✅ Сборка завершена успешно!"

# Проверка файлов
echo ""
echo "🔍 Проверка собранных файлов..."
if [ -f "dist/index.html" ]; then
    echo "✅ dist/index.html найден"
else
    echo "❌ dist/index.html не найден!"
    exit 1
fi

echo "📁 Содержимое папки dist:"
ls -la dist/

# Этап 2: Развертывание
echo ""
echo "📤 Этап 2: Загрузка на сервер..."
echo "Команда: ./deploy-to-vps.sh $SERVER_IP"

./deploy-to-vps.sh $SERVER_IP

if [ $? -eq 0 ]; then
    echo ""
    echo "🎉 Развертывание завершено успешно!"
    echo "🌐 Сайт доступен по адресу: http://$SERVER_IP"
else
    echo ""
    echo "❌ Ошибка развертывания"
    exit 1
fi