@echo off
echo 🚀 Развертывание медицинских дверей на VPS
echo =========================================

if "%1"=="" (
    echo ❌ Укажите IP адрес сервера
    echo Использование: deploy-to-vps.bat your-server-ip
    echo Пример: deploy-to-vps.bat 192.168.1.100
    pause
    exit /b 1
)

set SERVER_IP=%1
echo 📋 Сервер: %SERVER_IP%
echo.

echo 📦 Шаг 1: Проверка файлов сборки...
if not exist "dist\index.html" (
    echo ❌ Файлы сборки не найдены!
    echo Сначала соберите проект: npm run build
    echo Или используйте: fix-npm.bat
    pause
    exit /b 1
)

echo ✅ Файлы сборки найдены

echo.
echo 📤 Шаг 2: Создание архива для передачи...
set ARCHIVE_NAME=medical-doors-%date:~-4,4%%date:~-10,2%%date:~-7,2%-%time:~0,2%%time:~3,2%%time:~6,2%.tar.gz
tar -czf "%ARCHIVE_NAME%" -C dist .

if errorlevel 1 (
    echo ❌ Ошибка создания архива
    pause
    exit /b 1
)

echo ✅ Архив создан: %ARCHIVE_NAME%

echo.
echo 🔑 Шаг 3: Добавление SSH ключа...
ssh-keyscan -H %SERVER_IP% >> %%USERPROFILE%%\.ssh\known_hosts 2>nul

echo.
echo 📤 Шаг 4: Загрузка на сервер...
scp "%ARCHIVE_NAME%" root@%SERVER_IP%:/tmp/

if errorlevel 1 (
    echo ❌ Ошибка загрузки на сервер
    echo Проверьте доступность сервера: ping %SERVER_IP%
    del "%ARCHIVE_NAME%"
    pause
    exit /b 1
)

echo.
echo ⚙️ Шаг 5: Настройка сервера...
ssh -T root@%SERVER_IP% "cd /tmp && tar -xzf %ARCHIVE_NAME% -C /var/www/medical-doors/dist/ && rm %ARCHIVE_NAME% && chown -R www-data:www-data /var/www/medical-doors/dist && chmod -R 755 /var/www/medical-doors/dist"

if errorlevel 1 (
    echo ❌ Ошибка настройки сервера
    del "%ARCHIVE_NAME%"
    pause
    exit /b 1
)

echo.
echo 🎉 Развертывание завершено!
echo ========================================
echo 🌐 Сайт доступен по адресу: http://%SERVER_IP%
echo.
echo 📋 Что было сделано:
echo ✅ Проект собран
echo ✅ Файлы загружены на сервер
echo ✅ Nginx настроен
echo ✅ Права доступа установлены
echo.
echo 🔧 Для проверки:
echo ssh root@%SERVER_IP% "systemctl status nginx"
echo curl -I http://%SERVER_IP%
echo.
echo 📊 Мониторинг:
echo ssh root@%SERVER_IP% "tail -f /var/log/nginx/medical-doors_access.log"

del "%ARCHIVE_NAME%"
pause