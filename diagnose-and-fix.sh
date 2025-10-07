#!/bin/bash

# Диагностика и исправление проблем с сайтом
# Использование: ./diagnose-and-fix.sh

SERVER_IP="89.23.98.187"
DOMAIN="meddoors.dorren.ru"

echo "🔍 ДИАГНОСТИКА И ИСПРАВЛЕНИЕ ПРОБЛЕМ С САЙТОМ"
echo "============================================="

# Проверка локальных файлов
echo "🔍 Шаг 1: Диагностика локальных файлов..."
if [ ! -f "dist/index.html" ]; then
    echo "❌ Локальный index.html не найден!"
    echo "Сначала соберите проект: npm run build"
    exit 1
fi

echo "✅ Локальные файлы в порядке"

# Проверка изображений
echo "🖼️ Шаг 2: Проверка изображений..."
if [ -d "dist/assets/images" ]; then
    IMG_COUNT=$(find dist/assets/images/ -type f \( -iname "*.jpg" -o -iname "*.png" \) | wc -l)
    echo "✅ Изображения найдены: $IMG_COUNT файлов"
else
    echo "❌ Изображения не найдены локально"
    exit 1
fi

# Диагностика сервера
echo "🔍 Шаг 3: Диагностика сервера..."
ssh -o StrictHostKeyChecking=no root@$SERVER_IP << EOF
echo "=== ДИАГНОСТИКА СЕРВЕРА ==="
echo "Время: \$(date)"
echo "Пользователь: \$(whoami)"

echo ""
echo "=== СТАТУС NGINX ==="
systemctl status nginx --no-pager -l | grep -E "(Active|Loaded|Memory)" || echo "❌ Nginx не запущен"

echo ""
echo "=== ПРОВЕРКА КОНФИГУРАЦИИ ==="
nginx -t 2>&1 || echo "❌ Ошибка конфигурации nginx"

echo ""
echo "=== ФАЙЛЫ САЙТА ==="
if [ -d "/var/www/medical-doors/dist" ]; then
    echo "Папка сайта существует:"
    ls -la /var/www/medical-doors/dist/ 2>/dev/null | head -10

    echo ""
    echo "Изображения на сервере:"
    if [ -d "/var/www/medical-doors/dist/assets/images" ]; then
        SERVER_IMG_COUNT=\$(find /var/www/medical-doors/dist/assets/images/ -type f \( -iname "*.jpg" -o -iname "*.png" \) | wc -l)
        echo "✅ Изображения найдены: \$SERVER_IMG_COUNT файлов"
        find /var/www/medical-doors/dist/assets/images/ -type f \( -iname "*.jpg" -o -iname "*.png" \) | head -5
    else
        echo "❌ Папка изображений не найдена!"
    fi

    echo ""
    echo "Проверка основного файла:"
    if [ -f "/var/www/medical-doors/dist/index.html" ]; then
        echo "✅ index.html найден"
        head -3 /var/www/medical-doors/dist/index.html
    else
        echo "❌ index.html не найден!"
    fi
else
    echo "❌ Папка сайта не существует!"
fi

echo ""
echo "=== ЛОГИ ОШИБОК ==="
echo "Последние ошибки nginx:"
tail -10 /var/log/nginx/meddoors_error.log 2>/dev/null || tail -10 /var/log/nginx/error.log 2>/dev/null || echo "Логи недоступны"

echo ""
echo "=== ТЕСТ HTTP ЗАПРОСА ==="
echo "Тест HTTP:"
curl -I http://$DOMAIN 2>/dev/null | head -3 || echo "❌ HTTP не отвечает"

echo ""
echo "Тест HTTPS:"
curl -I https://$DOMAIN 2>/dev/null | head -3 || echo "❌ HTTPS не отвечает"

echo ""
echo "=== РЕКОМЕНДАЦИИ ПО ИСПРАВЛЕНИЮ ==="
echo "1. Если nginx не запущен: systemctl start nginx"
echo "2. Если ошибка конфигурации: nginx -t"
echo "3. Если файлы отсутствуют: загрузить файлы заново"
echo "4. Если изображения не найдены: проверить папку assets/images"
EOF

echo ""
echo "🔧 Шаг 4: Исправление обнаруженных проблем..."
echo "Проверка необходимости исправления..."

# Проверка нужно ли исправлять
ssh -o StrictHostKeyChecking=no root@$SERVER_IP "if [ ! -f '/var/www/medical-doors/dist/index.html' ] || [ ! -d '/var/www/medical-doors/dist/assets/images' ]; then echo 'Нужна загрузка файлов'; else echo 'Файлы на сервере есть'; fi"

SERVER_NEEDS_FIX=$(ssh -o StrictHostKeyChecking=no root@$SERVER_IP "if [ ! -f '/var/www/medical-doors/dist/index.html' ] || [ ! -d '/var/www/medical-doors/dist/assets/images' ]; then echo 'true'; else echo 'false'; fi")

if [ "$SERVER_NEEDS_FIX" = "true" ]; then
    echo "🔄 Обнаружены проблемы - выполняю исправление..."

    # Создание архива
    ARCHIVE_NAME="site-fix-$(date +%Y%m%d-%H%M%S).tar.gz"
    tar -czf "$ARCHIVE_NAME" -C dist .

    # Загрузка на сервер
    scp -o StrictHostKeyChecking=no "$ARCHIVE_NAME" root@$SERVER_IP:/tmp/

    # Исправление на сервере
    ssh -o StrictHostKeyChecking=no root@$SERVER_IP << EOF
echo "=== ИСПРАВЛЕНИЕ ПРОБЛЕМ ==="

echo "Создание резервной копии..."
cp -r /var/www/medical-doors/dist /var/www/medical-doors/dist.backup.fix.\$(date +%Y%m%d_%H%M%S) 2>/dev/null || echo "Резервная копия не создана"

echo "Остановка nginx..."
systemctl stop nginx 2>/dev/null || echo "nginx не запущен"

echo "Очистка старых файлов..."
rm -rf /var/www/medical-doors/dist/*

echo "Распаковка новых файлов..."
cd /var/www/medical-doors/dist
tar -xzf /tmp/$ARCHIVE_NAME

echo "Установка прав доступа..."
chown -R www-data:www-data /var/www/medical-doors/dist
chmod -R 755 /var/www/medical-doors/dist

echo "Очистка архива..."
rm /tmp/$ARCHIVE_NAME

echo "Проверка файлов после исправления:"
ls -la /var/www/medical-doors/dist/ | head -10

echo "Запуск nginx..."
nginx -t && systemctl start nginx

echo "Финальная проверка:"
echo "HTTP: \$(curl -I http://$DOMAIN 2>/dev/null | head -1)"
echo "HTTPS: \$(curl -I https://$DOMAIN 2>/dev/null | head -1)"

echo "✅ ИСПРАВЛЕНИЕ ЗАВЕРШЕНО!"
EOF

    # Очистка локального архива
    rm "$ARCHIVE_NAME"

    echo ""
    echo "🎉 ПРОБЛЕМЫ ИСПРАВЛЕНЫ!"
    echo "======================"
    echo "🌐 Проверьте сайт: https://$DOMAIN"
else
    echo "✅ Серьезных проблем не обнаружено"
    echo "Проверьте логи nginx для детальной диагностики"
fi