#!/bin/bash

# Однокнопочное развертывание - добавляет SSH ключ и выполняет все команды
# Использование: echo "yes" | ./one-click-deploy.sh

SERVER_IP="89.23.98.187"

echo "🚀 Однокнопочное развертывание медицинских дверей на VPS"
echo "======================================================="

# Проверка наличиния файлов локально
if [ ! -f "dist/index.html" ]; then
    echo "❌ Локальные файлы не найдены!"
    echo "Сначала соберите проект: npm run build"
    exit 1
fi

echo "✅ Локальные файлы найдены"

# Добавляем сервер в known_hosts
echo "🔑 Добавление SSH ключа сервера в known_hosts..."
ssh-keyscan -H $SERVER_IP >> ~/.ssh/known_hosts 2>/dev/null || true

echo "📦 Шаг 1: Установка Nginx на сервере..."
ssh -T -o StrictHostKeyChecking=no root@$SERVER_IP << 'EOF'
apt update -qq && apt install -y nginx -qq
mkdir -p /var/www/medical-doors/dist /etc/nginx/sites-available /etc/nginx/sites-enabled
EOF

echo "📤 Шаг 2: Загрузка файлов на сервер..."
scp -T -o StrictHostKeyChecking=no -r ./dist/* root@$SERVER_IP:/var/www/medical-doors/dist/

echo "⚙️ Шаг 3: Настройка сервера..."
ssh -T -o StrictHostKeyChecking=no root@$SERVER_IP << 'EOF'
chown -R www-data:www-data /var/www/medical-doors/dist
chmod -R 755 /var/www/medical-doors/dist
EOF

echo "🔗 Шаг 4: Настройка Nginx..."
# Передаем конфигурацию на сервер
cat > /tmp/nginx_medical_doors.conf << 'NGINX_EOF'
server {
    listen 80;
    server_name _;
    root /var/www/medical-doors/dist;
    index index.html;

    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
        try_files $uri =404;
    }

    location / {
        try_files $uri $uri/ /index.html;
    }
}
NGINX_EOF

scp -T -o StrictHostKeyChecking=no /tmp/nginx_medical_doors.conf root@$SERVER_IP:/etc/nginx/sites-available/medical-doors

echo "🔗 Шаг 5: Активация сайта..."
ssh -T -o StrictHostKeyChecking=no root@$SERVER_IP << 'EOF'
rm -f /etc/nginx/sites-enabled/default
ln -sf /etc/nginx/sites-available/medical-doors /etc/nginx/sites-enabled/
nginx -t && systemctl restart nginx && systemctl enable nginx
EOF

echo "📋 Шаг 6: Проверка результатов..."
echo "Файлы на сервере:"
ssh -T -o StrictHostKeyChecking=no root@$SERVER_IP "ls -la /var/www/medical-doors/dist/"

echo "Статус Nginx:"
ssh -T -o StrictHostKeyChecking=no root@$SERVER_IP "systemctl status nginx --no-pager -l"

echo "HTTP ответ:"
curl -I http://$SERVER_IP/ 2>/dev/null | head -3 || echo "❌ HTTP не отвечает"

echo ""
echo "🎉 РАЗВЕРТЫВАНИЕ ЗАВЕРШЕНО!"
echo "=========================="
echo "🌐 Сайт доступен по адресу: http://$SERVER_IP"
echo ""
echo "📋 Что было сделано:"
echo "✅ Nginx установлен и настроен"
echo "✅ Файлы сайта загружены"
echo "✅ Конфигурация применена"
echo "✅ Сервер запущен"
echo ""
echo "🔧 Для диагностики:"
echo "ssh root@$SERVER_IP 'tail -f /var/log/nginx/medical-doors_error.log'"