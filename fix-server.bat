@echo off
echo 🔧 Исправление сервера медицинских дверей
echo =========================================

set SERVER_IP=89.23.98.187

echo.
echo 📦 Шаг 1: Установка Nginx на сервере...
ssh -o StrictHostKeyChecking=no root@%SERVER_IP% "apt update && apt install -y nginx"

echo.
echo 📁 Шаг 2: Создание необходимых директорий...
ssh -o StrictHostKeyChecking=no root@%SERVER_IP% "mkdir -p /var/www/medical-doors/dist /etc/nginx/sites-available /etc/nginx/sites-enabled"

echo.
echo ⚙️ Шаг 3: Настройка Nginx...
ssh -o StrictHostKeyChecking=no root@%SERVER_IP% "tee /etc/nginx/sites-available/medical-doors > /dev/null" < nginx.conf

echo.
echo 🔗 Шаг 4: Активация сайта...
ssh -o StrictHostKeyChecking=no root@%SERVER_IP% "rm -f /etc/nginx/sites-enabled/default && ln -sf /etc/nginx/sites-available/medical-doors /etc/nginx/sites-enabled/"

echo.
echo 🔍 Шаг 5: Проверка и запуск Nginx...
ssh -o StrictHostKeyChecking=no root@%SERVER_IP% "nginx -t && systemctl restart nginx && systemctl enable nginx"

echo.
echo 📋 Шаг 6: Проверка статуса...
ssh -o StrictHostKeyChecking=no root@%SERVER_IP% "systemctl status nginx --no-pager"

echo.
echo ✅ Сервер исправлен!
echo ====================
echo.
echo 🌐 Проверьте сайт: http://%SERVER_IP%
echo.
echo 📁 Файлы должны быть доступны:
ssh -o StrictHostKeyChecking=no root@%SERVER_IP% "ls -la /var/www/medical-doors/dist/"
echo.
echo 🔧 Если сайт не работает:
echo ssh root@%SERVER_IP% "tail -f /var/log/nginx/medical-doors_error.log"
echo ssh root@%SERVER_IP% "systemctl restart nginx"

pause