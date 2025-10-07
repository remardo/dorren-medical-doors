@echo off
echo 🔍 Диагностика сервера медицинских дверей
echo =========================================

set SERVER_IP=89.23.98.187

echo.
echo 📋 Шаг 1: Проверка доступности сервера
echo Пинг сервера: %SERVER_IP%
ping -n 3 %SERVER_IP% >nul 2>&1
if errorlevel 1 (
    echo ❌ Сервер недоступен
) else (
    echo ✅ Сервер доступен
)

echo.
echo 🌐 Шаг 2: Проверка HTTP ответа
echo Проверка HTTP: http://%SERVER_IP%
curl -I http://%SERVER_IP% 2>nul | findstr "HTTP" || echo "❌ HTTP порт не отвечает"

echo.
echo 📁 Шаг 3: Проверка файлов на сервере
echo Подключение к серверу для проверки файлов...
ssh -o StrictHostKeyChecking=no root@%SERVER_IP% "ls -la /var/www/medical-doors/dist/" 2>nul || echo "❌ Не удалось подключиться или папка не существует"

echo.
echo ⚙️ Шаг 4: Проверка статуса Nginx
ssh -o StrictHostKeyChecking=no root@%SERVER_IP% "systemctl status nginx --no-pager" 2>nul | findstr "Active:" || echo "❌ Nginx не запущен или недоступен"

echo.
echo 📊 Шаг 5: Проверка логов Nginx
echo Последние записи в логах ошибок:
ssh -o StrictHostKeyChecking=no root@%SERVER_IP% "tail -5 /var/log/nginx/medical-doors_error.log 2>/dev/null || tail -5 /var/log/nginx/error.log 2>/dev/null || echo 'Логи недоступны'" 2>nul

echo.
echo 🔧 Рекомендации:
echo ================
echo.
echo 1. Если сервер недоступен:
echo    - Проверьте подключение к интернету
echo    - Проверьте правильность IP адреса
echo    - Убедитесь, что VPS сервер запущен
echo.
echo 2. Если HTTP порт не отвечает:
echo    - Убедитесь, что nginx установлен и запущен
echo    - Проверьте настройки firewall
echo.
echo 3. Если файлы не найдены на сервере:
echo    - Сначала соберите проект локально
echo    - Затем загрузите файлы на сервер
echo.
echo 4. Для полной настройки сервера выполните:
echo    curl -s https://raw.githubusercontent.com/.../server-setup.sh ^| ssh root@%SERVER_IP% "bash"
echo.
echo 📞 Если проблемы продолжаются, проверьте:
echo    - Статус VPS сервера у провайдера
echo    - Настройки firewall на сервере
echo    - Доступность порта 80

pause