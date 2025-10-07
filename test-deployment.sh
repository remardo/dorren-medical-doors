#!/bin/bash

# Скрипт для тестирования развертывания на сервере
# Использование: ./test-deployment.sh

echo "🧪 Тестирование развертывания медицинских дверей на VPS..."
echo "=================================================="

# Проверка 1: Статус nginx
echo "📋 Шаг 1: Проверка статуса nginx..."
sudo systemctl status nginx --no-pager -l

# Проверка 2: Конфигурация nginx
echo -e "\n📋 Шаг 2: Проверка конфигурации nginx..."
sudo nginx -t

# Проверка 3: Проверка файлов сайта
echo -e "\n📋 Шаг 3: Проверка файлов сайта..."
if [ -f "/var/www/medical-doors/dist/index.html" ]; then
    echo "✅ index.html найден"
    head -5 /var/www/medical-doors/dist/index.html
else
    echo "❌ index.html не найден в /var/www/medical-doors/dist/"
fi

# Проверка 4: Права доступа
echo -e "\n📋 Шаг 4: Проверка прав доступа..."
ls -la /var/www/medical-doors/dist/ | head -10

# Проверка 5: Проверка портов
echo -e "\n📋 Шаг 5: Проверка портов..."
sudo netstat -tlnp | grep :80 || echo "❌ Порт 80 не слушается"

# Проверка 6: Тест HTTP запроса
echo -e "\n📋 Шаг 6: Тест HTTP запроса..."
if command -v curl &> /dev/null; then
    curl -I http://localhost 2>/dev/null | head -5 || echo "❌ HTTP запрос не удался"
else
    echo "⚠️  curl не установлен"
fi

# Проверка 7: Логи ошибок
echo -e "\n📋 Шаг 7: Последние ошибки в логах..."
sudo tail -10 /var/log/nginx/medical-doors_error.log 2>/dev/null || echo "❌ Лог ошибок недоступен"

# Проверка 8: Процессы
echo -e "\n📋 Шаг 8: Активные процессы nginx..."
ps aux | grep nginx | grep -v grep

echo -e "\n🎯 Тестирование завершено!"
echo "=================================================="
echo "📝 Если все шаги показывают ✅, сайт должен работать корректно"
echo "🌐 Проверьте сайт в браузере: http://your-vps-ip"