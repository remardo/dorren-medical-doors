# 🚀 Быстрый запуск на VPS

Перенос сайта медицинских дверей на VPS за 15 минут!

## Требования
- VPS сервер с Ubuntu/Debian
- Доступ по SSH
- IP адрес сервера

## Шаг 1: Подготовка сервера (5 минут)

```bash
# Подключитесь к серверу
ssh root@your-vps-ip

# Обновите систему
sudo apt update && sudo apt upgrade -y

# Установите nginx
sudo apt install nginx -y

# Создайте папку для сайта
sudo mkdir -p /var/www/medical-doors/dist
```

## Шаг 2: Настройка сервера (5 минут)

```bash
# Создайте конфигурацию сайта
sudo nano /etc/nginx/sites-available/medical-doors
```

Вставьте:
```nginx
server {
    listen 80;
    server_name your-vps-ip;
    root /var/www/medical-doors/dist;
    index index.html;

    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }

    location / {
        try_files $uri $uri/ /index.html;
    }
}
```

```bash
# Активируйте сайт
sudo ln -s /etc/nginx/sites-available/medical-doors /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

## Шаг 3: Загрузка файлов (3 минуты)

На вашей локальной машине:

```bash
# Соберите проект
npm run build

# Загрузите файлы
scp -r ./dist/* root@your-vps-ip:/var/www/medical-doors/dist/

# Настройте права
ssh root@your-vps-ip "sudo chown -R www-data:www-data /var/www/medical-doors/dist"
```

## Шаг 4: Проверка (2 минуты)

Откройте браузер: `http://your-vps-ip`

Должны работать:
- ✅ Главная страница
- ✅ Кнопка "Получить техническое предложение"
- ✅ Форма консультации

## 🎉 Готово!

Ваш сайт медицинских дверей теперь работает на VPS!

---

## Дополнительно

### SSL сертификат (опционально)
```bash
sudo apt install certbot python3-certbot-nginx -y
sudo certbot --nginx -d your-domain.com
```

### Автоматическое развертывание
Используйте скрипт `deploy.sh` для автоматической загрузки обновлений.

### Подробная инструкция
Смотрите `STEP_BY_STEP_VPS_DEPLOY.md` для детального руководства.

---

## Полезные команды

```bash
# Статус сервера
sudo systemctl status nginx

# Логи
sudo tail -f /var/log/nginx/medical-doors_access.log

# Перезапуск
sudo systemctl restart nginx

# Тестирование
curl -I http://your-vps-ip