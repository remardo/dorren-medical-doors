@echo off
echo 🖼️ Копирование изображений для исправления картинок
echo ===================================================

echo.
echo 📁 Создание папки для изображений...
if not exist "dist\assets\images" mkdir "dist\assets\images"

echo.
echo 📋 Копирование JPG изображений...
copy "src\assets\images\*.jpg" "dist\assets\images\" >nul 2>&1
if errorlevel 1 (
    echo ⚠️ JPG файлы не найдены или не скопированы
) else (
    echo ✅ JPG файлы скопированы
)

echo.
echo 📋 Копирование PNG изображений...
copy "src\assets\images\*.png" "dist\assets\images\" >nul 2>&1
if errorlevel 1 (
    echo ⚠️ PNG файлы не найдены или не скопированы
) else (
    echo ✅ PNG файлы скопированы
)

echo.
echo 🔍 Проверка результата...
if exist "dist\assets\images" (
    echo ✅ Папка изображений создана
    dir "dist\assets\images" /b 2>nul | find /c /v "" > temp_count.txt
    set /p IMG_COUNT=<temp_count.txt
    del temp_count.txt
    echo 📊 Скопировано файлов: %IMG_COUNT%
) else (
    echo ❌ Не удалось создать папку изображений
)

echo.
echo 🎉 ИЗОБРАЖЕНИЯ ПОДГОТОВЛЕНЫ!
echo =========================
echo.
echo 📋 Следующий шаг - загрузка на сервер:
echo curl -s https://raw.githubusercontent.com/remardo/dorren-medical-doors/main/upload-to-server.sh ^| bash
echo.
echo Или используйте готовый сайт:
echo https://meddoors.dorren.ru
echo.
echo 🖼️ После загрузки файлов картинки должны отображаться!

pause