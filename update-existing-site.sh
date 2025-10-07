#!/bin/bash

# Обновление существующего сайта на VPS без изменения конфигурации
# Использование: ./update-existing-site.sh

SERVER_IP="89.23.98.187"
DOMAIN="meddoors.dorren.ru"

echo "🔄 Обновление существующего сайта на VPS"
echo "========================================"

# Проверка локальных файлов
echo "🔍 Проверка локальных файлов..."
if [ ! -f "dist/index.html" ]; then
    echo "❌ Локальные файлы не найдены!"
    echo "Сначала соберите проект: npm run build"
    exit 1
fi

echo "✅ Локальные файлы найдены"

# Проверка изображений
echo "🖼️ Проверка изображений..."
if [ ! -d "dist/assets/images" ]; then
    echo "❌ Изображения не найдены!"
    echo "Выполните копирование изображений сначала"
    exit 1
fi

echo "✅ Изображения найдены: $(ls dist/assets/images/ | wc -l) файлов"

# Создание архива только обновленных файлов
echo "📦 Создание архива обновлений..."
ARCHIVE_NAME="site-update-$(date +%Y%m%d-%H%M%S).tar.gz"
tar -czf "$ARCHIVE_NAME" -C dist .

# Загрузка на сервер
echo "📤 Загрузка обновлений на сервер..."
scp -o StrictHostKeyChecking=no "$ARCHIVE_NAME" root@$SERVER_IP:/tmp/

# Обновление файлов на сервере
echo "🔄 Обновление файлов на сервере..."
ssh -o StrictHostKeyChecking=no root@$SERVER_IP << EOF
# Остановка nginx для обновления
echo "🛑 Остановка nginx..."
systemctl stop nginx

# Создание резервной копии
echo "💾 Создание резервной копии..."
cp -r /var/www/medical-doors/dist /var/www/medical-doors/dist.backup.$(date +%Y%m%d_%H%M%S) 2>/dev/null || echo "Резервная копия пропущена"

# Очистка старых файлов
echo "🗑️ Очистка старых файлов..."
rm -rf /var/www/medical-doors/dist/*

# Распаковка новых файлов
echo "📋 Распаковка обновлений..."
cd /var/www/medical-doors/dist
tar -xzf /tmp/$ARCHIVE_NAME

# Восстановление прав доступа
echo "🔐 Восстановление прав доступа..."
chown -R www-data:www-data /var/www/medical-doors/dist
chmod -R 755 /var/www/medical-doors/dist

# Очистка архива
rm /tmp/$ARCHIVE_NAME

# Проверка файлов
echo "📁 Проверка новых файлов:"
ls -la /var/www/medical-doors/dist/ | head -10

# Запуск nginx
echo "🚀 Запуск nginx..."
systemctl start nginx

echo "✅ Файлы обновлены успешно!"
EOF

# Очистка локального архива
rm "$ARCHIVE_NAME"

echo ""
echo "🎉 САЙТ УСПЕШНО ОБНОВЛЕН!"
echo "========================"
echo "🌐 Проверьте обновленный сайт: https://$DOMAIN"
echo ""
echo "📋 Что было обновлено:"
echo "✅ HTML, CSS и JavaScript файлы"
echo "✅ Изображения продуктов"
echo "✅ Компоненты React"
echo "✅ Настройки и конфигурация"
echo ""
echo "🔒 SSL сертификаты и настройки сервера сохранены"
echo "⚙️ Конфигурация nginx не изменена"
echo ""
echo "🖼️ Теперь картинки должны загружаться корректно!"