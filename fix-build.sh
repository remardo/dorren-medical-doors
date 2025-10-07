#!/bin/bash

# Скрипт исправления проблем со сборкой проекта в Windows/WSL
# Использование: ./fix-build.sh

echo "🔧 Исправление проблем со сборкой проекта"
echo "========================================"

# Определение платформы
PLATFORM=$(uname -s)
echo "📋 Обнаружена платформа: $PLATFORM"

if [[ "$PLATFORM" == *"MINGW"* ]] || [[ "$PLATFORM" == *"MSYS"* ]]; then
    echo "🪟 Обнаружена Windows среда"
elif [[ "$PLATFORM" == "Linux" ]]; then
    if grep -q "microsoft" /proc/version 2>/dev/null; then
        echo "🐧 Обнаружена WSL (Windows Subsystem for Linux)"
    else
        echo "🐧 Обнаружена чистая Linux среда"
    fi
fi

echo ""
echo "🔨 Применение решений..."
echo ""

# Решение 1: Очистка и переустановка зависимостей
echo "📦 Решение 1: Переустановка зависимостей..."
if [ -d "node_modules" ]; then
    echo "🗑️ Удаление node_modules..."
    rm -rf node_modules
fi

if [ -f "package-lock.json" ]; then
    echo "🗑️ Удаление package-lock.json..."
    rm -f package-lock.json
fi

echo "📥 Установка зависимостей..."
npm install

if [ $? -ne 0 ]; then
    echo "❌ Ошибка установки зависимостей"
    echo ""
    echo "🔧 Альтернативные решения:"
    echo "1. Попробуйте использовать yarn:"
    echo "   npm install -g yarn"
    echo "   yarn install"
    echo ""
    echo "2. Используйте npm с флагом --force:"
    echo "   npm install --force"
    echo ""
    exit 1
fi

# Решение 2: Попытка сборки
echo ""
echo "🔨 Решение 2: Попытка сборки..."
npm run build

if [ $? -ne 0 ]; then
    echo ""
    echo "❌ Сборка всё ещё не работает"
    echo ""
    echo "🔧 Дополнительные решения:"
    echo ""
    echo "1. Проверьте версию Node.js:"
    echo "   node --version  # Должна быть 16+"
    echo "   npm --version   # Должна быть 8+"
    echo ""
    echo "2. Попробуйте очистить кэш npm:"
    echo "   npm cache clean --force"
    echo "   rm -rf ~/.npm"
    echo "   npm install"
    echo ""
    echo "3. Используйте альтернативный сборщик:"
    echo "   npx vite build --mode development"
    echo ""
    echo "4. Проверьте наличие всех файлов:"
    echo "   ls -la src/"
    echo "   ls -la public/"
    echo ""
    exit 1
fi

echo ""
echo "✅ Сборка успешна!"
echo "📁 Проверьте папку dist:"
ls -la dist/

echo ""
echo "🎉 Теперь можете использовать скрипты развертывания:"
echo "   ./deploy-to-vps.sh your-server-ip"
echo "   ./auto-deploy.sh root@your-server-ip"