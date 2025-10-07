@echo off
echo 🔍 Диагностика сервера медицинских дверей
echo =========================================

set SERVER_IP=89.23.98.187

echo.
echo 📋 Шаг 1: Проверка доступности сервера
ping -n 3 %SERVER_IP% >nul 2>&1
if errorlevel 1 (
    echo ❌ Сервер %SERVER_IP% недоступен
) else (
    echo ✅ Сервер %SERVER_IP% доступен
)

echo.
echo 🌐 Шаг 2: Проверка HTTP порта
curl -I http://%SERVER_IP% 2>nul | findstr "HTTP" >nul
if errorlevel 1 (
    echo ❌ HTTP порт не отвечает
) else (
    echo ✅ HTTP порт отвечает
    curl -I http://%SERVER_IP% 2>nul | findstr "HTTP"
)

echo.
echo 📁 Шаг 3: Проверка файлов сайта
echo Файлы в папке сайта:
ssh -o StrictHostKeyChecking=no root@%SERVER_IP% "ls -la /var/www/medical-doors/dist/" 2>nul || echo "❌ Не удалось проверить файлы"

echo.
echo ⚙️ Шаг 4: Проверка Nginx
ssh -o StrictHostKeyChecking=no root@%SERVER_IP% "systemctl status nginx --no-pager" 2>nul | findstr "Active:" || echo "❌ Nginx не запущен"

echo.
echo 📊 Шаг 5: Логи ошибок Nginx
echo Последние ошибки Nginx:
ssh -o StrictHostKeyChecking=no root@%SERVER_IP% "tail -10 /var/log/nginx/medical-doors_error.log 2>/dev/null || tail -10 /var/log/nginx/error.log 2>/dev/null || echo 'Логи недоступны'" 2>nul

echo.
echo 🔍 Шаг 6: Логи доступа Nginx
echo Последние запросы:
ssh -o StrictHostKeyChecking=no root@%SERVER_IP% "tail -5 /var/log/nginx/medical-doors_access.log 2>/dev/null || tail -5 /var/log/nginx/access.log 2>/dev/null || echo 'Логи доступа недоступны'" 2>nul

echo.
echo 🔧 Шаг 7: Процессы Nginx
ssh -o StrictHostKeyChecking=no root@%SERVER_IP% "ps aux | grep nginx | grep -v grep" 2>nul || echo "❌ Процессы Nginx не найдены"

echo.
echo 📋 РЕЗЮМЕ ДИАГНОСТИКИ:
echo ====================
echo.
echo Если сервер недоступен:
echo   - Проверьте подключение к интернету
echo   - Проверьте статус VPS у провайдера
echo.
echo Если HTTP порт не отвечает:
echo   - Установите Nginx: apt install -y nginx
echo   - Запустите Nginx: systemctl start nginx
echo.
echo Если файлы отсутствуют:
echo   - Сначала соберите проект локально
echo   - Затем загрузите файлы на сервер
echo.
echo Если Nginx запущен, но сайт не работает:
echo   - Проверьте конфигурацию Nginx
echo   - Проверьте права доступа к файлам
echo   - Смотрите логи ошибок

pause