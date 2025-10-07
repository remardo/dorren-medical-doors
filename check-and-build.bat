@echo off
echo 🔍 Проверка и сборка проекта медицинских дверей
echo ==============================================

echo.
echo 📋 Шаг 1: Проверка текущей директории
cd
echo Текущая директория: %cd%

echo.
echo 📦 Шаг 2: Проверка зависимостей
if not exist "node_modules" (
    echo ❌ node_modules не найдена
    echo 📥 Установка зависимостей...
    call npm install
    if errorlevel 1 (
        echo ❌ Ошибка установки зависимостей
        pause
        exit /b 1
    )
) else (
    echo ✅ node_modules найдена
)

echo.
echo 🔨 Шаг 3: Сборка проекта
echo Выполняется: npm run build
call npm run build

if errorlevel 1 (
    echo.
    echo ❌ Ошибка сборки проекта
    echo.
    echo 🔧 Возможные решения:
    echo 1. Используйте скрипт исправления: fix-npm.bat
    echo 2. Удалите node_modules и установите заново
    echo 3. Проверьте наличие всех файлов в папках src и public
    pause
    exit /b 1
)

echo.
echo ✅ Сборка завершена успешно!

echo.
echo 📁 Шаг 4: Проверка файлов сборки
if exist "dist\index.html" (
    echo ✅ Файл dist\index.html найден
    dir dist /b
) else (
    echo ❌ Файлы сборки не найдены в папке dist
    echo Ожидаемая папка: dist\
    dir *.html 2>nul
)

echo.
echo 🎉 Проект готов для развертывания!
echo.
echo 🚀 Следующий шаг - развертывание на сервер:
echo    deploy-to-vps.bat 89.23.98.187
echo.
echo Или в WSL/Git Bash:
echo    ./deploy-to-vps.sh 89.23.98.187

pause