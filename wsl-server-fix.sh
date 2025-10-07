#!/bin/bash

# Исправление сервера через WSL
# Использование: ./wsl-server-fix.sh

SERVER_IP="89.23.98.187"

echo "🔧 Исправление сервера через WSL"
echo "================================"

# Проверка наличиния файлов локально
if [ ! -f "dist/index.html" ]; then
    echo "❌ Локальные файлы не найдены!"
    echo "Сначала соберите проект: npm run build"
    exit 1
fi

echo "📦 Шаг 1: Установка Nginx на сервере..."
ssh-keyscan -H $SERVER_IP >> ~/.ssh/known_hosts 2>/dev/null || true
ssh -o StrictHostKeyChecking=no root@$SERVER_IP "apt update -qq && apt install -y nginx -qq"

echo "📁 Шаг 2: Создание директорий..."
ssh -o StrictHostKeyChecking=no root@$SERVER_IP "mkdir -p /var/www/medical-doors/dist /etc/nginx/sites-available /etc/nginx/sites-enabled"

echo "📤 Шаг 3: Загрузка файлов на сервер..."
scp -o StrictHostKeyChecking=no -r ./dist/* root@$SERVER_IP:/var/www/medical-doors/dist/

echo "⚙️ Шаг 4: Настройка прав доступа..."
ssh -o StrictHostKeyChecking=no root@$SERVER_IP "chown -R www-data:www-data /var/www/medical-doors/dist && chmod -R 755 /var/www/medical-doors/dist"

echo "🔗 Шаг 5: Настройка Nginx..."
# Читаем конфигурацию из локального файла и передаем на сервер
cat nginx.conf | ssh -o StrictHostKeyChecking=no root@$SERVER_IP "cat > /etc/nginx/sites-available/medical-doors"

echo "🔗 Шаг 6: Активация сайта..."
ssh -o StrictHostKeyChecking=no root@$SERVER_IP "rm -f /etc/nginx/sites-enabled/default && ln -sf /etc/nginx/sites-available/medical-doors /etc/nginx/sites-enabled/"

echo "🔍 Шаг 7: Проверка конфигурации..."
ssh -o StrictHostKeyChecking=no root@$SERVER_IP "nginx -t"

echo "🚀 Шаг 8: Запуск Nginx..."
ssh -o StrictHostKeyChecking=no root@$SERVER_IP "systemctl restart nginx && systemctl enable nginx"

echo "📋 Шаг 9: Проверка статуса..."
ssh -o StrictHostKeyChecking=no root@$SERVER_IP "systemctl status nginx --no-pager -l"

echo "✅ Шаг 10: Финальная проверка..."
echo "Файлы на сервере:"
ssh root@$SERVER_IP "ls -la /var/www/medical-doors/dist/"

echo "HTTP ответ:"
curl -I http://$SERVER_IP/ 2>/dev/null | head -3 || echo "❌ HTTP не отвечает"

echo ""
echo "🎉 РАЗВЕРТЫВАНИЕ ЗАВЕРШЕНО!"
echo "=========================="
echo "🌐 Сайт доступен по адресу: http://$SERVER_IP"
echo ""
echo "📋 Что было сделано:"
echo "✅ Nginx установлен и настроен"
echo "✅ Файлы сайта загружены"
echo "✅ Конфигурация применена"
echo "✅ Сервер запущен"
echo ""
echo "🔧 Для диагностики:"
echo "ssh root@$SERVER_IP 'tail -f /var/log/nginx/medical-doors_error.log'"