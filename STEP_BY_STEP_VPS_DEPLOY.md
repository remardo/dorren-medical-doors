# Пошаговая инструкция: Перенос сайта медицинских дверей на VPS

## Подготовка

### Шаг 0: Проверьте готовность проекта

Убедитесь, что:
- ✅ Проект собирается без ошибок: `npm run build`
- ✅ В папке `dist/` есть файлы `index.html`, `assets/`
- ✅ У вас есть доступ к VPS серверу по SSH

---

## Часть 1: Настройка сервера

### Шаг 1: Подключитесь к серверу

```bash
ssh root@your-vps-ip
# или
ssh user@your-vps-ip
```

**Проверка:** Если подключение успешно, вы увидите командную строку сервера.

### Шаг 2: Обновите систему

```bash
sudo apt update && sudo apt upgrade -y
```

**Проверка:**
```bash
lsb_release -a  # Должна показать Ubuntu/Debian версию
```

### Шаг 3: Установите необходимые программы

```bash
# Установка nginx
sudo apt install nginx -y

# Установка дополнительных инструментов
sudo apt install curl wget git htop nano -y

# Установка Node.js (если планируете локальную разработку на сервере)
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt-get install -y nodejs
```

**Проверка:**
```bash
nginx -v                    # Должна показать версию nginx
node --version             # Должна показать версию Node.js
sudo systemctl status nginx # Должен показать активный статус
```

### Шаг 4: Создайте директорию для сайта

```bash
sudo mkdir -p /var/www/medical-doors/dist
sudo chown -R $USER:$USER /var/www/medical-doors
cd /var/www/medical-doors
```

**Проверка:**
```bash
pwd  # Должна показать /var/www/medical-doors
ls -la  # Должна показать папку dist
```

### Шаг 5: Настройте firewall (опционально)

```bash
sudo ufw allow 'Nginx Full'
sudo ufw allow ssh
sudo ufw enable
sudo ufw status
```

---

## Часть 2: Конфигурация веб-сервера

### Шаг 6: Создайте конфигурацию Nginx

```bash
sudo nano /etc/nginx/sites-available/medical-doors
```

Вставьте следующую конфигурацию:

```nginx
server {
    listen 80;
    server_name your-vps-ip;  # Замените на ваш IP или домен

    root /var/www/medical-doors/dist;
    index index.html;

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

    # Логи
    access_log /var/log/nginx/medical-doors_access.log;
    error_log /var/log/nginx/medical-doors_error.log;
}
```

### Шаг 7: Активируйте сайт

```bash
# Удалите дефолтный сайт (если он есть)
sudo rm /etc/nginx/sites-enabled/default

# Активируйте наш сайт
sudo ln -s /etc/nginx/sites-available/medical-doors /etc/nginx/sites-enabled/

# Проверьте конфигурацию
sudo nginx -t

# Перезагрузите nginx
sudo systemctl reload nginx
```

**Проверка:**
```bash
sudo nginx -t  # Должна быть синтаксис OK
sudo systemctl status nginx  # Должен быть active (running)
```

---

## Часть 3: Загрузка файлов сайта

### Шаг 8: Подготовьте файлы на локальной машине

На вашей локальной машине (не на сервере):

```bash
# Убедитесь, что находитесь в папке проекта
pwd  # Должна показать путь к проекту медицинских дверей

# Соберите проект
npm run build

# Проверьте содержимое папки dist
ls -la dist/
```

### Шаг 9: Загрузите файлы на сервер

**Вариант A: Через SCP (рекомендуется для первого раза)**

```bash
# Скопируйте всю папку dist
scp -r ./dist/* root@your-vps-ip:/var/www/medical-doors/dist/

# Альтернатива: создайте архив для ускорения передачи
tar -czf medical-doors.tar.gz -C dist .
scp medical-doors.tar.gz root@your-vps-ip:/var/www/medical-doors/
```

**Вариант B: Через rsync (для синхронизации)**

```bash
# Установите rsync если его нет
sudo apt install rsync -y

# Синхронизируйте файлы
rsync -avz --delete ./dist/ root@your-vps-ip:/var/www/medical-doors/dist/
```

### Шаг 10: Настройте права доступа на сервере

```bash
# На сервере выполните:
sudo chown -R www-data:www-data /var/www/medical-doors/dist
sudo chmod -R 755 /var/www/medical-doors/dist
find /var/www/medical-doors/dist -type f -exec chmod 644 {} \;
```

**Проверка:**
```bash
ls -la /var/www/medical-doors/dist/
# Должен показать www-data как владельца
```

---

## Часть 4: Тестирование и проверка

### Шаг 11: Проверьте работу сайта

Откройте браузер и перейдите по адресу:
- `http://your-vps-ip`

**Что должно произойти:**
- ✅ Страница должна загрузиться
- ✅ Должны отображаться медицинские двери
- ✅ Должна работать кнопка "Получить техническое предложение"
- ✅ Должна работать форма консультации

### Шаг 12: Проверьте логи

```bash
# Просмотр логов доступа
sudo tail -f /var/log/nginx/medical-doors_access.log

# Просмотр логов ошибок
sudo tail -f /var/log/nginx/medical-doors_error.log
```

### Шаг 13: Проверьте процессы

```bash
# Статус nginx
sudo systemctl status nginx

# Активные соединения
sudo netstat -tlnp | grep :80
```

---

## Часть 5: Домены и SSL (опционально)

### Шаг 14: Подключите домен (если есть)

```bash
# Измените конфигурацию nginx
sudo nano /etc/nginx/sites-available/medical-doors
# Замените your-vps-ip на your-domain.com

# Перезагрузите nginx
sudo systemctl reload nginx
```

### Шаг 15: Установите SSL сертификат

```bash
# Установите certbot
sudo apt install certbot python3-certbot-nginx -y

# Получите сертификат
sudo certbot --nginx -d your-domain.com

# Автоматическое обновление сертификатов
sudo systemctl enable certbot.timer
```

**Проверка:**
```bash
sudo certbot certificates  # Должен показать активный сертификат
```

---

## Часть 6: Автоматизация развертывания

### Шаг 16: Настройте автоматическое развертывание (опционально)

```bash
# На сервере создайте git репозиторий
cd /var/www/medical-doors
git init --bare

# Создайте post-receive хук
nano /var/www/medical-doors.git/hooks/post-receive
```

Вставьте в хук:

```bash
#!/bin/bash
git --work-tree=/var/www/medical-doors/dist --git-dir=/var/www/medical-doors.git checkout -f
cd /var/www/medical-doors/dist
sudo chown -R www-data:www-data /var/www/medical-doors/dist
sudo systemctl reload nginx
```

```bash
# Сделайте хук исполняемым
chmod +x /var/www/medical-doors.git/hooks/post-receive
```

---

## Проверка финальной работы

### Шаг 17: Финальные тесты

1. **Откройте сайт в браузере:**
   - `http://your-vps-ip` или `https://your-domain.com`

2. **Проверьте функциональность:**
   - ✅ Главная страница загружается
   - ✅ Меню навигации работает
   - ✅ Кнопка "Получить техническое предложение" прокручивает к форме
   - ✅ Форма консультации отправляет данные в Telegram

3. **Проверьте производительность:**
   ```bash
   curl -I http://your-vps-ip  # Должен показать HTTP 200
   ```

---

## Устранение проблем

### Проблема: Сайт не загружается
```bash
# Проверьте:
sudo systemctl status nginx
sudo nginx -t
sudo tail -f /var/log/nginx/medical-doors_error.log
```

### Проблема: Нет доступа к порту 80
```bash
sudo ufw status
sudo netstat -tlnp | grep :80
sudo ss -tlnp | grep :80
```

### Проблема: Файлы не загружаются
```bash
# Проверьте права доступа
ls -la /var/www/medical-doors/dist/
sudo chown -R www-data:www-data /var/www/medical-doors/dist

# Проверьте содержимое index.html
head -20 /var/www/medical-doors/dist/index.html
```

### Проблема: Ошибки JavaScript
```bash
# Проверьте консоль браузера (F12)
# Убедитесь, что все файлы assets загружаются корректно
```

---

## Мониторинг и поддержка

### Полезные команды для мониторинга:

```bash
# Статус сервисов
sudo systemctl status nginx

# Использование ресурсов
htop

# Доступ к логам
sudo tail -f /var/log/nginx/medical-doors_access.log

# Перезапуск сервисов
sudo systemctl restart nginx

# Проверка конфигурации
sudo nginx -t
```

---

## Следующие шаги после развертывания

1. **Настройте резервное копирование**
2. **Настройте мониторинг** (например, через Grafana)
3. **Подключите аналитику** (Google Analytics, Yandex Metrika)
4. **Настройте CI/CD** для автоматического развертывания

---

## Контакты поддержки

Если возникнут проблемы:
1. Проверьте логи: `/var/log/nginx/medical-doors_error.log`
2. Убедитесь, что сервер доступен: `ping your-vps-ip`
3. Проверьте статус сервисов: `sudo systemctl status nginx`

---

**Поздравляем! Ваш сайт медицинских дверей теперь работает на VPS! 🚀**