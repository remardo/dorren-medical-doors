#!/bin/bash

# Копирование изображений в папку dist для исправления проблемы с картинками
# Использование: ./copy-images.sh

echo "🖼️ Копирование изображений в папку dist"
echo "======================================="

# Проверка исходных файлов
echo "🔍 Проверка исходных изображений..."
if [ -d "src/assets/images" ]; then
    echo "✅ Исходные изображения найдены:"
    ls -la src/assets/images/*.jpg | head -5
else
    echo "❌ Папка src/assets/images не найдена"
    exit 1
fi

# Создание папки для изображений в dist
echo "📁 Создание папки для изображений..."
mkdir -p dist/assets/images

# Копирование изображений
echo "📋 Копирование изображений..."
cp src/assets/images/*.jpg dist/assets/images/ 2>/dev/null || echo "Копирование JPG файлов..."
cp src/assets/images/*.png dist/assets/images/ 2>/dev/null || echo "Копирование PNG файлов..."

# Проверка результата
echo "🔍 Проверка результата..."
if [ -d "dist/assets/images" ]; then
    echo "✅ Изображения скопированы:"
    ls -la dist/assets/images/ | head -10

    # Подсчет файлов
    JPG_COUNT=$(ls dist/assets/images/*.jpg 2>/dev/null | wc -l)
    PNG_COUNT=$(ls dist/assets/images/*.png 2>/dev/null | wc -l)
    echo "📊 Скопировано: $JPG_COUNT JPG, $PNG_COUNT PNG файлов"
else
    echo "❌ Не удалось создать папку dist/assets/images"
    exit 1
fi

echo ""
echo "🎉 ИЗОБРАЖЕНИЯ СКОПИРОВАНЫ!"
echo "=========================="
echo "🖼️ Теперь картинки должны загружаться корректно"
echo ""
echo "📋 Следующий шаг - загрузка на сервер:"
echo "curl -s https://raw.githubusercontent.com/remardo/dorren-medical-doors/main/upload-to-server.sh | bash"