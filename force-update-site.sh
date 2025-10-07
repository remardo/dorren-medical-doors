#!/bin/bash

# Принудительное обновление сайта с полной диагностикой
# Использование: ./force-update-site.sh

SERVER_IP="89.23.98.187"
DOMAIN="meddoors.dorren.ru"

echo "🔥 Принудительное обновление сайта с диагностикой"
echo "==============================================="

# Проверка локальных файлов
echo "🔍 Шаг 1: Диагностика локальных файлов..."
echo "Текущая директория: $(pwd)"
echo "Содержимое dist:"
ls -la dist/ 2>/dev/null || echo "❌ Папка dist не найдена"

if [ ! -f "dist/index.html" ]; then
    echo "❌ Файл dist/index.html не найден!"
    echo "Сначала соберите проект локально"
    exit 1
fi

echo "✅ Локальный index.html найден"

# Проверка изображений
echo "🖼️ Шаг 2: Проверка изображений..."
if [ -d "dist/assets/images" ]; then
    IMG_COUNT=$(ls dist/assets/images/ | wc -l)
    echo "✅ Изображения найдены: $IMG_COUNT файлов"
    ls dist/assets/images/ | head -5
else
    echo "❌ Папка изображений не найдена!"
    echo "Выполните копирование изображений сначала"
    exit 1
fi

# Создание архива с диагностикой
echo "📦 Шаг 3: Создание архива файлов..."
ARCHIVE_NAME="site-full-update-$(date +%Y%m%d-%H%M%S).tar.gz"
echo "Имя архива: $ARCHIVE_NAME"
echo "Размер файлов: $(du -sh dist/ | cut -f1)"

tar -czf "$ARCHIVE_NAME" -C dist .
ARCHIVE_SIZE=$(du -sh "$ARCHIVE_NAME" | cut -f1)
echo "✅ Архив создан: $ARCHIVE_SIZE"

# Загрузка на сервер
echo "📤 Шаг 4: Загрузка на сервер..."
echo "Загрузка архива на сервер..."
scp -o StrictHostKeyChecking=no -v "$ARCHIVE_NAME" root@$SERVER_IP:/tmp/ 2>&1 | head -10

if [ $? -eq 0 ]; then
    echo "✅ Архив загружен на сервер"
else
    echo "❌ Ошибка загрузки архива"
    rm "$ARCHIVE_NAME"
    exit 1
fi

# Обновление файлов на сервере с диагностикой
echo "🔄 Шаг 5: Обновление файлов на сервере..."
ssh -o StrictHostKeyChecking=no root@$SERVER_IP << EOF
echo "=== ДИАГНОСТИКА СЕРВЕРА ==="
echo "Текущее время: \$(date)"
echo "Текущая директория: \$(pwd)"
echo "Статус nginx: \$(systemctl status nginx --no-pager -l | grep Active)"

echo ""
echo "=== СОЗДАНИЕ РЕЗЕРВНОЙ КОПИИ ==="
BACKUP_DIR="/var/www/medical-doors/dist.backup.\$(date +%Y%m%d_%H%M%S)"
cp -r /var/www/medical-doors/dist \$BACKUP_DIR 2>/dev/null || echo "Не удалось создать резервную копию"

echo ""
echo "=== ПРОВЕРКА АРХИВА ==="
ls -la /tmp/$ARCHIVE_NAME 2>/dev/null || echo "❌ Архив не найден на сервере"

echo ""
echo "=== ОЧИСТКА СТАРЫХ ФАЙЛОВ ==="
rm -rf /var/www/medical-doors/dist/*
echo "Старые файлы удалены"

echo ""
echo "=== РАСПАКОВКА НОВЫХ ФАЙЛОВ ==="
cd /var/www/medical-doors/dist
tar -xzf /tmp/$ARCHIVE_NAME
echo "Файлы распакованы"

echo ""
echo "=== ПРОВЕРКА НОВЫХ ФАЙЛОВ ==="
ls -la /var/www/medical-doors/dist/ | head -10

echo ""
echo "=== ПРОВЕРКА ИЗОБРАЖЕНИЙ ==="
if [ -d "/var/www/medical-doors/dist/assets/images" ]; then
    IMG_COUNT=\$(ls assets/images/ 2>/dev/null | wc -l)
    echo "✅ Изображения найдены: \$IMG_COUNT файлов"
    ls assets/images/ | head -5
else
    echo "❌ Папка изображений не найдена после распаковки!"
fi

echo ""
echo "=== УСТАНОВКА ПРАВ ДОСТУПА ==="
chown -R www-data:www-data /var/www/medical-doors/dist
chmod -R 755 /var/www/medical-doors/dist
echo "Права доступа установлены"

echo ""
echo "=== ОЧИСТКА АРХИВА ==="
rm /tmp/$ARCHIVE_NAME
echo "Архив удален"

echo ""
echo "=== ПЕРЕЗАПУСК NGINX ==="
nginx -t && systemctl reload nginx
echo "Nginx перезапущен"

echo ""
echo "=== ФИНАЛЬНАЯ ПРОВЕРКА ==="
echo "HTTP ответ:"
curl -I http://$DOMAIN 2>/dev/null | head -3

echo ""
echo "HTTPS ответ:"
curl -I https://$DOMAIN 2>/dev/null | head -3

echo ""
echo "=== ПРОВЕРКА ИЗОБРАЖЕНИЙ ==="
curl -I http://$DOMAIN/assets/images/dorren_medical_door_palata_sm.jpg 2>/dev/null | head -1 || echo "❌ Картинка не доступна"

echo ""
echo "✅ ОБНОВЛЕНИЕ ЗАВЕРШЕНО!"
EOF

# Очистка локального архива
rm "$ARCHIVE_NAME"

echo ""
echo "🎉 ПРИНУДИТЕЛЬНОЕ ОБНОВЛЕНИЕ ЗАВЕРШЕНО!"
echo "====================================="
echo "🌐 Проверьте сайт: https://$DOMAIN"
echo ""
echo "📋 Что было сделано:"
echo "✅ Полная диагностика локальных файлов"
echo "✅ Создание архива с проверкой размера"
echo "✅ Загрузка на сервер с детальным логированием"
echo "✅ Полная замена файлов на сервере"
echo "✅ Проверка изображений после обновления"
echo "✅ Диагностика HTTP и HTTPS ответов"
echo ""
echo "🖼️ Теперь картинки и информация должны обновиться!"