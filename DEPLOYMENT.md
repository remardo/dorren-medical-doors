# Развертывание на VPS

## Шаг 1: Подготовка сервера

### Установка необходимого ПО на Ubuntu/Debian VPS:

```bash
# Обновление системы
sudo apt update && sudo apt upgrade -y

# Установка Node.js (если нужно для сборки)
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt-get install -y nodejs

# Установка nginx
sudo apt install nginx -y

# Установка certbot для SSL (опционально)
sudo apt install certbot python3-certbot-nginx -y

# Установка PM2 для управления процессами (если нужно)
sudo npm install -g pm2
```

## Шаг 2: Конфигурация Nginx

Создайте файл конфигурации сайта:

```bash
sudo nano /etc/nginx/sites-available/medical-doors
```

Содержимое файла:

```nginx
server {
    listen 80;
    server_name your-domain.com www.your-domain.com;

    root /var/www/medical-doors/dist;
    index index.html;

    # Gzip сжатие
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_proxied any;
    gzip_comp_level 6;
    gzip_types
        text/plain
        text/css
        text/xml
        text/javascript
        application/javascript
        application/xml+rss
        application/json;

    # Кеширование статических файлов
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
        try_files $uri =404;
    }

    # Обработка SPA (React Router)
    location / {
        try_files $uri $uri/ /index.html;
    }

    # Безопасность
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;

    # Логи
    access_log /var/log/nginx/medical-doors_access.log;
    error_log /var/log/nginx/medical-doors_error.log;
}
```

Активируйте сайт:

```bash
sudo ln -s /etc/nginx/sites-available/medical-doors /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

## Шаг 3: Загрузка файлов на сервер

### Способ 1: Через SFTP/SCP

```bash
# Скопируйте файлы из папки dist в директорию сервера
scp -r ./dist/* user@your-vps-ip:/var/www/medical-doors/dist/
```

### Способ 2: Через Git (рекомендуется для автоматического развертывания)

```bash
# На сервере создайте git репозиторий
sudo mkdir -p /var/www/medical-doors
cd /var/www/medical-doors
sudo git init --bare

# На локальной машине добавьте remote
git remote add production user@your-vps-ip:/var/www/medical-doors.git
git push production main
```

## Шаг 4: Настройка SSL сертификата (опционально)

```bash
sudo certbot --nginx -d your-domain.com -d www.your-domain.com
```

## Шаг 5: Автоматическое развертывание (опционально)

Создайте post-receive хук:

```bash
sudo nano /var/www/medical-doors.git/hooks/post-receive
```

Содержимое:

```bash
#!/bin/bash
git --work-tree=/var/www/medical-doors/dist --git-dir=/var/www/medical-doors.git checkout -f
cd /var/www/medical-doors/dist
sudo systemctl reload nginx
```

Сделайте файл исполняемым:

```bash
sudo chmod +x /var/www/medical-doors.git/hooks/post-receive
```

## Шаг 6: Мониторинг и логи

```bash
# Проверка статуса nginx
sudo systemctl status nginx

# Просмотр логов
sudo tail -f /var/log/nginx/medical-doors_access.log
sudo tail -f /var/log/nginx/medical-doors_error.log

# Перезапуск nginx при необходимости
sudo systemctl restart nginx
```

## Переменные окружения

Создайте файл `.env` на сервере если нужно:

```bash
# В директории /var/www/medical-doors/dist/
echo "VITE_API_URL=https://your-domain.com/api" > .env
```

## Производительность

Для лучшей производительности рекомендуется:

1. Настроить CDN для статических файлов
2. Включить HTTP/2 в nginx
3. Настроить кеширование в браузере
4. Оптимизировать изображения

## Диагностика проблем

```bash
# Проверка конфигурации nginx
sudo nginx -t

# Проверка портов
sudo netstat -tlnp | grep :80

# Проверка процессов
sudo ps aux | grep nginx