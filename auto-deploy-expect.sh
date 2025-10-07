#!/bin/bash

# Развертывание с автоматическим ответом на SSH запросы
# Требует expect: apt install expect
# Использование: ./auto-deploy-expect.sh

SERVER_IP="89.23.98.187"

echo "🚀 Автоматическое развертывание с expect"
echo "========================================"

# Проверка наличиния файлов локально
if [ ! -f "dist/index.html" ]; then
    echo "❌ Локальные файлы не найдены!"
    echo "Сначала соберите проект: npm run build"
    exit 1
fi

echo "✅ Локальные файлы найдены"

# Проверка наличия expect
if ! command -v expect &> /dev/null; then
    echo "📦 Установка expect..."
    sudo apt update -qq && sudo apt install -y expect -qq
fi

# Создание expect скрипта для автоматизации SSH
cat > /tmp/ssh_deploy.exp << 'EXPECT_EOF'
#!/usr/bin/expect -f

set SERVER_IP "89.23.98.187"
set timeout 30

spawn ssh root@$SERVER_IP "apt update -qq && apt install -y nginx -qq && mkdir -p /var/www/medical-doors/dist /etc/nginx/sites-available /etc/nginx/sites-enabled"

expect {
    "The authenticity of host*" {
        send "yes\r"
        exp_continue
    }
    "password:" {
        send "YOUR_PASSWORD\r"
        exp_continue
    }
    eof
}

spawn scp -r ./dist/* root@$SERVER_IP:/var/www/medical-doors/dist/

expect {
    "The authenticity of host*" {
        send "yes\r"
        exp_continue
    }
    "password:" {
        send "YOUR_PASSWORD\r"
        exp_continue
    }
    eof
}

puts "Файлы загружены успешно"
EXPECT_EOF

echo "⚠️ ВАЖНО: Отредактируйте скрипт /tmp/ssh_deploy.exp"
echo "Замените YOUR_PASSWORD на реальный пароль root пользователя"
echo ""
echo "Затем выполните:"
echo "expect /tmp/ssh_deploy.exp"