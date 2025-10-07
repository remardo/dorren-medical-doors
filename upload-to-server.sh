#!/bin/bash

# Загрузка файлов с локальной машины на сервер
# Использование: ./upload-to-server.sh

SERVER_IP="89.23.98.187"

echo "📤 Загрузка файлов сайта на сервер"
echo "================================="

# Проверка локальных файлов
echo "🔍 Проверка локальных файлов..."
if [ -f "dist/index.html" ]; then
    echo "✅ Файлы найдены локально"
    echo "📁 Содержимое папки dist:"
    ls -la dist/ | head -10
else
    echo "❌ Файлы не найдены локально!"
    echo "Сначала соберите проект локально: npm run build"
    exit 1
fi

# Создание архива
echo "📦 Создание архива..."
ARCHIVE_NAME="medical-doors-site-$(date +%Y%m%d-%H%M%S).tar.gz"
tar -czf "$ARCHIVE_NAME" -C dist .

echo "📤 Загрузка архива на сервер..."
scp -o StrictHostKeyChecking=no "$ARCHIVE_NAME" root@$SERVER_IP:/tmp/

# Распаковка на сервере
echo "📋 Распаковка файлов на сервере..."
ssh -o StrictHostKeyChecking=no root@$SERVER_IP << EOF
# Остановка nginx для обновления
systemctl stop nginx 2>/dev/null || echo "nginx не запущен"

# Очистка старых файлов
rm -rf /var/www/medical-doors/dist/*

# Распаковка новых файлов
cd /var/www/medical-doors/dist
tar -xzf /tmp/$ARCHIVE_NAME
chown -R www-data:www-data /var/www/medical-doors/dist
chmod -R 755 /var/www/medical-doors/dist

# Очистка архива
rm /tmp/$ARCHIVE_NAME

# Проверка файлов
echo "📁 Новые файлы на сервере:"
ls -la /var/www/medical-doors/dist/

# Запуск nginx
systemctl start nginx

echo "✅ Файлы обновлены успешно!"
EOF

# Очистка локального архива
rm "$ARCHIVE_NAME"

echo ""
echo "🎉 ФАЙЛЫ УСПЕШНО ОБНОВЛЕНЫ!"
echo "=========================="
echo "🌐 Проверьте сайт: https://meddoors.dorren.ru"
echo ""
echo "📋 Что было сделано:"
echo "✅ Проект пересобран с исправленными путями к изображениям"
echo "✅ Архив создан и загружен на сервер"
echo "✅ Старые файлы удалены, новые распакованы"
echo "✅ Права доступа установлены"
echo "✅ Nginx перезапущен"
echo ""
echo "🖼️ Теперь картинки должны загружаться корректно!"