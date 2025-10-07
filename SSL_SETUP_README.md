# 🔒 Настройка SSL сертификатов для meddoors.dorren.ru

## Требования для получения SSL сертификата

Перед настройкой SSL убедитесь, что:
- ✅ Домен `meddoors.dorren.ru` указывает на IP `89.23.98.187`
- ✅ Сайт работает по HTTP: `http://meddoors.dorren.ru`
- ✅ Порт 80 открыт и доступен
- ✅ Nginx установлен и настроен

## Быстрая настройка SSL (рекомендуется)

### Шаг 1: Подключитесь к серверу
```bash
ssh root@89.23.98.187
```

### Шаг 2: Выполните команды
```bash
# Обновление системы
apt update && apt upgrade -y

# Установка certbot
apt install -y certbot python3-certbot-nginx

# Получение SSL сертификата
certbot --nginx -d meddoors.dorren.ru -d www.meddoors.dorren.ru
```

### Шаг 3: Выберите опции
- Введите email для уведомлений
- Согласитесь с условиями сервиса (A)
- Выберите редирект HTTP на HTTPS (2)

## Альтернативный способ (если certbot не работает)

### Шаг 1: Установка certbot
```bash
apt install -y certbot python3-certbot-nginx
```

### Шаг 2: Настройка DNS (если не настроен)
Убедитесь, что домен `meddoors.dorren.ru` указывает на `89.23.98.187`

### Шаг 3: Получение сертификата
```bash
# Остановка nginx
systemctl stop nginx

# Получение сертификата в автономном режиме
certbot certonly --standalone -d meddoors.dorren.ru -d www.meddoors.dorren.ru

# Запуск nginx
systemctl start nginx
```

### Шаг 4: Настройка HTTPS в nginx
Отредактируйте `/etc/nginx/sites-available/meddoors.dorren.ru`:
```nginx
server {
    listen 80;
    server_name meddoors.dorren.ru www.meddoors.dorren.ru;
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name meddoors.dorren.ru www.meddoors.dorren.ru;

    ssl_certificate /etc/letsencrypt/live/meddoors.dorren.ru/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/meddoors.dorren.ru/privkey.pem;

    # ... остальная конфигурация
}
```

## Проверка SSL сертификата

### Шаг 1: Проверка сертификата
```bash
# Проверка активных сертификатов
certbot certificates

# Проверка срока действия
openssl x509 -in /etc/letsencrypt/live/meddoors.dorren.ru/cert.pem -text -noout | grep -A 2 "Validity"
```

### Шаг 2: Тестирование HTTPS
```bash
# Тест HTTPS ответа
curl -I https://meddoors.dorren.ru

# Тест безопасности SSL
curl https://www.ssllabs.com/ssltest/analyze.html?d=meddoors.dorren.ru
```

## Автоматическое обновление сертификатов

### Настройка автобновления
```bash
# Включение автобновления
systemctl enable certbot.timer
systemctl start certbot.timer

# Проверка статуса
systemctl status certbot.timer

# Ручное обновление
certbot renew --dry-run
```

## Диагностика проблем

### Если сертификат не получается
```bash
# Проверка доступности порта 80
netstat -tlnp | grep :80

# Проверка DNS
nslookup meddoors.dorren.ru

# Проверка firewall
ufw status

# Логи certbot
tail -f /var/log/letsencrypt/letsencrypt.log
```

### Если HTTPS не работает
```bash
# Проверка конфигурации nginx
nginx -t

# Проверка сертификатов
ls -la /etc/letsencrypt/live/meddoors.dorren.ru/

# Перезапуск nginx
systemctl reload nginx
```

## Управление сертификатами

### Просмотр сертификатов
```bash
certbot certificates
```

### Обновление сертификата
```bash
certbot renew
```

### Отзыв сертификата
```bash
certbot revoke --cert-name meddoors.dorren.ru
```

### Удаление сертификата
```bash
certbot delete --cert-name meddoors.dorren.ru
```

## Оптимизация SSL

### Улучшение производительности
```nginx
# В секцию server добавьте:
ssl_session_cache shared:SSL:10m;
ssl_session_timeout 10m;
ssl_protocols TLSv1.2 TLSv1.3;
ssl_ciphers ECDHE-RSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384;
ssl_prefer_server_ciphers off;
```

### Безопасность
```nginx
# Заголовки безопасности
add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
add_header X-Frame-Options "SAMEORIGIN" always;
add_header X-Content-Type-Options "nosniff" always;
```

## Результат

После настройки SSL:
- ✅ `http://meddoors.dorren.ru` → `https://meddoors.dorren.ru`
- ✅ Зеленый замочек в браузере
- ✅ Защищенное соединение
- ✅ Автоматическое обновление сертификатов

---

## Полезные команды

```bash
# Статус сертификатов
certbot certificates

# Обновление сертификатов
certbot renew

# Логи certbot
tail -f /var/log/letsencrypt/letsencrypt.log

# Проверка HTTPS
curl -I https://meddoors.dorren.ru

# Диагностика SSL
openssl s_client -connect meddoors.dorren.ru:443