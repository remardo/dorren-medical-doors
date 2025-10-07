@echo off
echo 🔧 Исправление npm зависимостей для Windows...
echo ============================================

echo.
echo 📦 Шаг 1: Удаление node_modules и package-lock.json

REM Остановка процессов Node.js
taskkill /f /im node.exe 2>nul
taskkill /f /im npm.exe 2>nul
taskkill /f /im vite.exe 2>nul
timeout /t 2 /nobreak >nul

if exist node_modules (
    echo 🗑️ Удаление node_modules...
    rmdir /s /q node_modules 2>nul || (
        echo ⚠️ Не удалось удалить node_modules обычным способом
        echo 🔧 Альтернативный метод удаления...
        echo Закройте все терминалы и редакторы кода, затем нажмите любую клавишу
        pause
        rmdir /s /q node_modules 2>nul || (
            echo ❌ Критическая ошибка: Не удается удалить node_modules
            echo Вручную удалите папку node_modules в проводнике
            echo Или используйте команду: rd /s /q node_modules
            pause
            exit /b 1
        )
    )
)

if exist package-lock.json (
    echo 🗑️ Удаление package-lock.json...
    del package-lock.json 2>nul
)

echo.
echo 📥 Шаг 2: Переустановка зависимостей
echo Выполняется: npm install
call npm install

if errorlevel 1 (
    echo.
    echo ❌ Ошибка установки зависимостей
    echo.
    echo 🔧 Попробуйте альтернативные решения:
    echo 1. Используйте yarn: npm install -g yarn ^& yarn install
    echo 2. Очистите кэш: npm cache clean --force
    echo 3. Проверьте подключение к интернету
    pause
    exit /b 1
)

echo.
echo 🔨 Шаг 3: Попытка сборки
call npm run build

if %errorlevel% equ 0 (
    echo.
    echo ✅ Сборка успешна!
    echo 📁 Проверьте папку dist
    dir dist /b
    echo.
    echo 🚀 Теперь можете использовать скрипты развертывания:
    echo    deploy-to-vps.bat 89.23.98.187
) else (
    echo.
    echo ❌ Ошибка сборки
    echo.
    echo 🔧 Попробуйте альтернативные решения:
    echo 1. Используйте yarn: npm install -g yarn ^& yarn install ^& yarn build
    echo 2. Очистите кэш: npm cache clean --force
    echo 3. Проверьте наличие всех файлов в папках src и public
)

pause