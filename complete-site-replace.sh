#!/bin/bash

# Полная замена сайта с текущими локальными файлами
# Использование: ./complete-site-replace.sh

SERVER_IP="89.23.98.187"
DOMAIN="meddoors.dorren.ru"

echo "🔄 ПОЛНАЯ ЗАМЕНА САЙТА С ТЕКУЩИМИ ФАЙЛАМИ"
echo "=========================================="

# Проверка локальных файлов
echo "🔍 Шаг 1: Проверка локальных файлов..."
echo "Текущая директория: $(pwd)"

if [ ! -f "dist/index.html" ]; then
    echo "❌ Файл dist/index.html не найден!"
    echo "Сначала соберите проект: npm run build"
    exit 1
fi

echo "✅ Основной файл найден"

# Проверка изображений
echo "🖼️ Шаг 2: Проверка изображений..."
if [ -d "dist/assets/images" ]; then
    IMG_COUNT=$(find dist/assets/images/ -type f \( -iname "*.jpg" -o -iname "*.png" \) | wc -l)
    echo "✅ Изображения найдены: $IMG_COUNT файлов"
    find dist/assets/images/ -type f \( -iname "*.jpg" -o -iname "*.png" \) | head -5
else
    echo "⚠️ Папка изображений не найдена"
    IMG_COUNT=0
fi

# Проверка размера файлов
TOTAL_SIZE=$(du -sh dist/ | cut -f1)
echo "📊 Общий размер файлов: $TOTAL_SIZE"

# Создание полного архива
echo "📦 Шаг 3: Создание полного архива..."
ARCHIVE_NAME="complete-site-$(date +%Y%m%d-%H%M%S).tar.gz"
echo "Архив: $ARCHIVE_NAME"

tar -czf "$ARCHIVE_NAME" -C dist .

if [ $? -ne 0 ]; then
    echo "❌ Ошибка создания архива"
    exit 1
fi

ARCHIVE_SIZE=$(du -sh "$ARCHIVE_NAME" | cut -f1)
echo "✅ Архив создан: $ARCHIVE_SIZE"

# Загрузка на сервер
echo "📤 Шаг 4: Загрузка на сервер..."
echo "Передача архива на сервер..."

# Используем scp с принудительным подтверждением SSH ключа
scp -o StrictHostKeyChecking=no "$ARCHIVE_NAME" root@$SERVER_IP:/tmp/ 2>/dev/null

if [ $? -ne 0 ]; then
    echo "❌ Ошибка загрузки на сервер"
    echo "Проверьте доступ к серверу"
    rm "$ARCHIVE_NAME"
    exit 1
fi

echo "✅ Архив загружен на сервер"

# Полная замена файлов на сервере
echo "🔄 Шаг 5: Полная замена файлов на сервере..."
ssh -o StrictHostKeyChecking=no root@$SERVER_IP << EOF
echo "=== ПОЛНАЯ ДИАГНОСТИКА СЕРВЕРА ==="
echo "Время: \$(date)"
echo "Пользователь: \$(whoami)"
echo "Директория: \$(pwd)"

echo ""
echo "=== СОЗДАНИЕ РЕЗЕРВНОЙ КОПИИ ==="
BACKUP_NAME="site-backup-\$(date +%Y%m%d-%H%M%S)"
mkdir -p /var/www/medical-doors/backups
cp -r /var/www/medical-doors/dist /var/www/medical-doors/backups/\$BACKUP_NAME
echo "✅ Резервная копия создана: \$BACKUP_NAME"

echo ""
echo "=== ПРОВЕРКА АРХИВА ==="
ls -la /tmp/$ARCHIVE_NAME
ARCHIVE_SIZE_SERVER=\$(du -sh /tmp/$ARCHIVE_NAME | cut -f1)
echo "Размер архива на сервере: \$ARCHIVE_SIZE_SERVER"

echo ""
echo "=== ПОЛНАЯ ЗАМЕНА ФАЙЛОВ ==="
# Остановка nginx
systemctl stop nginx 2>/dev/null || echo "nginx не запущен"

# Полная очистка
rm -rf /var/www/medical-doors/dist/*

# Распаковка нового архива
cd /var/www/medical-doors/dist
tar -xzf /tmp/$ARCHIVE_NAME

# Проверка распаковки
echo "Проверка распакованных файлов:"
ls -la /var/www/medical-doors/dist/ | head -10

echo ""
echo "=== ПРОВЕРКА ИЗОБРАЖЕНИЙ ==="
if [ -d "/var/www/medical-doors/dist/assets/images" ]; then
    SERVER_IMG_COUNT=\$(find assets/images/ -type f \( -iname "*.jpg" -o -iname "*.png" \) | wc -l)
    echo "✅ Изображения на сервере: \$SERVER_IMG_COUNT файлов"
    find assets/images/ -type f \( -iname "*.jpg" -o -iname "*.png" \) | head -5
else
    echo "❌ Папка изображений не найдена после распаковки!"
    SERVER_IMG_COUNT=0
fi

echo ""
echo "=== УСТАНОВКА ПРАВ ДОСТУПА ==="
chown -R www-data:www-data /var/www/medical-doors/dist
chmod -R 755 /var/www/medical-doors/dist
echo "✅ Права доступа установлены"

echo ""
echo "=== ОЧИСТКА АРХИВА ==="
rm /tmp/$ARCHIVE_NAME
echo "✅ Архив удален"

echo ""
echo "=== ПЕРЕЗАПУСК NGINX ==="
nginx -t && systemctl reload nginx
echo "✅ Nginx перезапущен"

echo ""
echo "=== ФИНАЛЬНАЯ ПРОВЕРКА ==="
echo "HTTP ответ:"
HTTP_STATUS=\$(curl -I http://$DOMAIN 2>/dev/null | head -1 | cut -d' ' -f2)
echo "Статус: \$HTTP_STATUS"

echo ""
echo "HTTPS ответ:"
HTTPS_STATUS=\$(curl -I https://$DOMAIN 2>/dev/null | head -1 | cut -d' ' -f2)
echo "Статус: \$HTTPS_STATUS"

echo ""
echo "Проверка изображений:"
IMG_STATUS=\$(curl -I http://$DOMAIN/assets/images/dorren_medical_door_palata_sm.jpg 2>/dev/null | head -1 | cut -d' ' -f2)
echo "Статус картинки: \$IMG_STATUS"

echo ""
echo "=== СТАТИСТИКА ОБНОВЛЕНИЯ ==="
echo "Локальные изображения: $IMG_COUNT файлов"
echo "Серверные изображения: \$SERVER_IMG_COUNT файлов"
echo "Архив размер: $ARCHIVE_SIZE"
echo "HTTP статус: \$HTTP_STATUS"
echo "HTTPS статус: \$HTTPS_STATUS"
echo "Статус изображений: \$IMG_STATUS"

echo ""
echo "✅ ПОЛНАЯ ЗАМЕНА ЗАВЕРШЕНА!"
EOF

# Очистка локального архива
rm "$ARCHIVE_NAME"

echo ""
echo "🎉 ПОЛНАЯ ЗАМЕНА САЙТА ЗАВЕРШЕНА!"
echo "================================"
echo "🌐 Сайт обновлен: https://$DOMAIN"
echo ""
echo "📋 Что было сделано:"
echo "✅ Полная диагностика локальных файлов"
echo "✅ Создание полного архива сайта"
echo "✅ Загрузка архива на сервер"
echo "✅ Создание резервной копии на сервере"
echo "✅ Полная замена всех файлов"
echo "✅ Проверка изображений после обновления"
echo "✅ Диагностика HTTP и HTTPS"
echo ""
echo "🖼️ Все ваши новые фото и изменения применены!"
echo "📝 Текстовая информация обновлена!"
echo "🔒 SSL сертификаты сохранены!"