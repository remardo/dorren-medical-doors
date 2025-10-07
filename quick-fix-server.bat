@echo off
echo 🚀 Быстрое исправление сервера медицинских дверей
echo =================================================

set SERVER_IP=89.23.98.187

echo.
echo 📦 Шаг 1: Установка Nginx...
ssh -o StrictHostKeyChecking=no root@%SERVER_IP% "apt update -qq && apt install -y nginx -qq"

echo.
echo 📁 Шаг 2: Создание директорий...
ssh -o StrictHostKeyChecking=no root@%SERVER_IP% "mkdir -p /var/www/medical-doors/dist /etc/nginx/sites-available /etc/nginx/sites-enabled"

echo.
echo ⚙️ Шаг 3: Настройка Nginx...
REM Читаем конфигурацию из файла и передаем на сервер
type nginx.conf | ssh -o StrictHostKeyChecking=no root@%SERVER_IP% "cat > /etc/nginx/sites-available/medical-doors"

echo.
echo 🔗 Шаг 4: Активация сайта...
ssh -o StrictHostKeyChecking=no root@%SERVER_IP% "rm -f /etc/nginx/sites-enabled/default && ln -sf /etc/nginx/sites-available/medical-doors /etc/nginx/sites-enabled/"

echo.
echo 🔍 Шаг 5: Проверка и запуск...
ssh -o StrictHostKeyChecking=no root@%SERVER_IP% "nginx -t && systemctl restart nginx && systemctl enable nginx"

echo.
echo 📋 Шаг 6: Проверка файлов...
ssh -o StrictHostKeyChecking=no root@%SERVER_IP% "ls -la /var/www/medical-doors/dist/"

echo.
echo ✅ Шаг 7: Проверка HTTP...
curl -I http://%SERVER_IP% 2>nul | findstr "HTTP" || echo "❌ HTTP не отвечает"

echo.
echo 🎉 ИСПРАВЛЕНИЕ ЗАВЕРШЕНО!
echo =========================
echo.
echo 🌐 Проверьте сайт: http://%SERVER_IP%
echo.
echo 📊 Для диагностики используйте:
echo   check-server.bat    - Полная диагностика
echo   show-logs.bat       - Просмотр логов
echo.
echo 🔧 Если сайт не работает:
echo   ssh root@%SERVER_IP% "tail -f /var/log/nginx/medical-doors_error.log"

pause