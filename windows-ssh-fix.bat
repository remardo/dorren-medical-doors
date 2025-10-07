@echo off
echo 🔧 Исправление SSH для Windows
echo ===============================
echo.
echo Проблема: Windows cmd не правильно обрабатывает SSH пароли
echo Решение: Используйте WSL или Git Bash для SSH команд
echo.
echo 📋 РЕКОМЕНДАЦИИ:
echo ===============
echo.
echo ВАРИАНТ 1 - WSL (рекомендуется):
echo   1. Откройте WSL: wsl
echo   2. Перейдите в папку проекта: cd /mnt/c/Users/remardo/dorren_med
echo   3. Выполните команды:
echo      ./deploy-to-vps.sh 89.23.98.187
echo      ssh root@89.23.98.187 "apt install -y nginx"
echo.
echo ВАРИАНТ 2 - Git Bash:
echo   1. Установите Git for Windows: https://gitforwindows.org/
echo   2. Запустите Git Bash
echo   3. Выполните команды SSH
echo.
echo ВАРИАНТ 3 - PuTTY (графический):
echo   1. Скачайте PuTTY: https://www.putty.org/
echo   2. Подключитесь к серверу: root@89.23.98.187
echo   3. Выполните команды установки Nginx
echo.
echo ВАРИАНТ 4 - Веб-интерфейс VPS провайдера:
echo   - Зайдите в панель управления VPS
echo   - Подключитесь через веб-консоль
echo   - Выполните команды установки
echo.
echo 📝 КОМАНДЫ ДЛЯ ВЫПОЛНЕНИЯ НА СЕРВЕРЕ:
echo =====================================
echo.
echo После подключения через WSL/Git Bash/PuTTY выполните:
echo.
echo 1. Обновление системы:
echo    apt update && apt upgrade -y
echo.
echo 2. Установка Nginx:
echo    apt install -y nginx
echo.
echo 3. Создание директорий:
echo    mkdir -p /var/www/medical-doors/dist
echo    mkdir -p /etc/nginx/sites-available
echo    mkdir -p /etc/nginx/sites-enabled
echo.
echo 4. Проверка файлов сайта:
echo    ls -la /var/www/medical-doors/dist/
echo.
echo 5. Настройка Nginx (скопируйте содержимое nginx.conf):
echo    nano /etc/nginx/sites-available/medical-doors
echo.
echo 6. Активация сайта:
echo    ln -sf /etc/nginx/sites-available/medical-doors /etc/nginx/sites-enabled/
echo    rm -f /etc/nginx/sites-enabled/default
echo.
echo 7. Запуск Nginx:
echo    nginx -t
echo    systemctl restart nginx
echo    systemctl enable nginx
echo.
echo 8. Проверка:
echo    curl -I http://localhost
echo    systemctl status nginx
echo.
echo 🌐 После настройки проверьте: http://89.23.98.187
echo.
echo 💡 Если проблемы с паролем в WSL:
echo    - Проверьте правильность IP адреса
echo    - Убедитесь, что VPS сервер запущен
echo    - Свяжитесь с провайдером VPS

pause