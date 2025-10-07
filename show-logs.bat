@echo off
echo 📊 Просмотр логов сервера медицинских дверей
echo ============================================

set SERVER_IP=89.23.98.187

echo.
echo 🔍 Логи ошибок Nginx:
echo ====================
ssh -o StrictHostKeyChecking=no root@%SERVER_IP% "echo '=== Логи ошибок Nginx ===' && tail -20 /var/log/nginx/medical-doors_error.log 2>/dev/null || tail -20 /var/log/nginx/error.log 2>/dev/null || echo 'Логи ошибок недоступны'" 2>nul

echo.
echo 📈 Логи доступа Nginx:
echo =====================
ssh -o StrictHostKeyChecking=no root@%SERVER_IP% "echo '=== Логи доступа Nginx ===' && tail -10 /var/log/nginx/medical-doors_access.log 2>/dev/null || tail -10 /var/log/nginx/access.log 2>/dev/null || echo 'Логи доступа недоступны'" 2>nul

echo.
echo 🔧 Статус Nginx:
echo ===============
ssh -o StrictHostKeyChecking=no root@%SERVER_IP% "echo '=== Статус Nginx ===' && systemctl status nginx --no-pager -l" 2>nul | findstr "Active:\|Loaded:\|Memory:\|CPU:" || echo "❌ Nginx не запущен или недоступен"

echo.
echo 📁 Файлы сайта:
echo ==============
ssh -o StrictHostKeyChecking=no root@%SERVER_IP% "echo '=== Файлы сайта ===' && ls -la /var/www/medical-doors/dist/ 2>/dev/null || echo '❌ Директория сайта недоступна'" 2>nul

echo.
echo 🌐 Тест HTTP ответа:
echo ===================
curl -v http://%SERVER_IP%/ 2>&1 | head -15 || echo "❌ Не удалось получить HTTP ответ"

echo.
echo 💡 АНАЛИЗ ПРОБЛЕМЫ:
echo ===================
echo.
echo Если видите "Welcome to nginx" в браузере:
echo   - Файлы сайта не найдены или не настроена конфигурация
echo   - Проверьте: ls -la /var/www/medical-doors/dist/
echo.
echo Если Nginx не запущен:
echo   - Установите Nginx: apt install -y nginx
echo   - Запустите: systemctl start nginx
echo.
echo Если файлы отсутствуют:
echo   - Сначала соберите проект локально: npm run build
echo   - Затем загрузите файлы: ./deploy-to-vps.sh %SERVER_IP%
echo.
echo Если конфигурация неправильная:
echo   - Скопируйте конфиг: scp nginx.conf root@%SERVER_IP%:/etc/nginx/sites-available/medical-doors
echo   - Активируйте сайт: ln -sf /etc/nginx/sites-available/medical-doors /etc/nginx/sites-enabled/
echo   - Перезагрузите: nginx -t ^&^& systemctl reload nginx

pause