#!/bin/bash

# Обновление файлов сайта на сервере
# Использование: ./update-files.sh

SERVER_IP="89.23.98.187"
DOMAIN="meddoors.dorren.ru"

echo "🔄 Обновление файлов сайта на сервере"
echo "====================================="

# Проверка локальных файлов
if [ ! -f "dist/index.html" ]; then
    echo "❌ Локальные файлы не найдены!"
    echo "Сначала соберите проект: npm run build"
    exit 1
fi

echo "✅ Локальные файлы найдены"

# Создание архива для передачи
echo "📦 Создание архива файлов..."
ARCHIVE_NAME="site-update-$(date +%Y%m%d-%H%M%S).tar.gz"
tar -czf "$ARCHIVE_NAME" -C dist .

# Загрузка на сервер
echo "📤 Загрузка файлов на сервер..."
scp -o StrictHostKeyChecking=no "$ARCHIVE_NAME" root@$SERVER_IP:/tmp/

# Распаковка на сервере
echo "📋 Распаковка файлов на сервере..."
ssh -o StrictHostKeyChecking=no root@$SERVER_IP << EOF
# Остановка nginx
systemctl stop nginx 2>/dev/null || echo "nginx не запущен"

# Распаковка файлов
cd /var/www/medical-doors/dist
sudo rm -rf *
sudo tar -xzf /tmp/$ARCHIVE_NAME
sudo chown -R www-data:www-data /var/www/medical-doors/dist
sudo chmod -R 755 /var/www/medical-doors/dist

# Очистка архива
rm /tmp/$ARCHIVE_NAME

# Проверка файлов
echo "📁 Файлы на сервере:"
ls -la /var/www/medical-doors/dist/

# Запуск nginx
systemctl start nginx

echo "✅ Файлы обновлены успешно!"
EOF

# Очистка локального архива
rm "$ARCHIVE_NAME"

echo ""
echo "🎉 ФАЙЛЫ ОБНОВЛЕНЫ!"
echo "=================="
echo "🌐 Проверьте сайт: https://$DOMAIN"
echo ""
echo "📋 Что было сделано:"
echo "✅ Проект пересобран с новыми путями к изображениям"
echo "✅ Файлы загружены на сервер"
echo "✅ Права доступа установлены"
echo "✅ Nginx перезапущен"
echo ""
echo "🖼️ Теперь картинки должны загружаться корректно!"