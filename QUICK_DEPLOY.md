# Быстрое развертывание на VPS

## Предварительные требования

1. VPS сервер с Ubuntu/Debian
2. Доступ по SSH
3. Домен (опционально)

## Шаг 1: Подготовка сервера

Выполните команды на сервере:

```bash
# Установка ПО
sudo apt update
sudo apt install nginx git -y

# Создание директории для сайта
sudo mkdir -p /var/www/medical-doors/dist
sudo chown -R $USER:$USER /var/www/medical-doors
```

## Шаг 2: Конфигурация Nginx

```bash
# Скопируйте конфигурацию
sudo cp nginx.conf /etc/nginx/sites-available/medical-doors
sudo ln -s /etc/nginx/sites-available/medical-doors /etc/nginx/sites-enabled/

# Замените your-domain.com на ваш домен или IP
sudo nano /etc/nginx/sites-available/medical-doors

# Проверка и перезапуск
sudo nginx -t
sudo systemctl reload nginx
```

## Шаг 3: Загрузка файлов

### Вариант A: Через скрипт (рекомендуется)

```bash
# Сделайте скрипт исполняемым
chmod +x deploy.sh

# Запустите развертывание
./deploy.sh user@your-vps-ip /var/www/medical-doors
```

### Вариант B: Вручную

```bash
# Скопируйте файлы
scp -r ./dist/* user@your-vps-ip:/var/www/medical-doors/dist/

# Настройте права доступа
ssh user@your-vps-ip "sudo chown -R www-data:www-data /var/www/medical-doors/dist"
```

## Шаг 4: Проверка

Откройте браузер и перейдите по адресу:
- `http://your-vps-ip` - если без домена
- `http://your-domain.com` - если с доменом

## Шаг 5: SSL сертификат (опционально)

```bash
# Установка certbot
sudo apt install certbot python3-certbot-nginx -y

# Получение сертификата
sudo certbot --nginx -d your-domain.com
```

## Команды для управления

```bash
# Статус nginx
sudo systemctl status nginx

# Перезапуск nginx
sudo systemctl restart nginx

# Просмотр логов
sudo tail -f /var/log/nginx/medical-doors_access.log
```

## Структура проекта на сервере

```
/var/www/medical-doors/
├── dist/           # Скомпилированные файлы
│   ├── index.html
│   ├── assets/
│   └── ...
└── nginx.conf      # Конфигурация (опционально)
```

## Переменные окружения

Если нужны переменные окружения, создайте файл `.env` в папке `dist/` на сервере.

## Автоматическое развертывание

Для автоматического развертывания через Git:

1. Настройте bare репозиторий на сервере
2. Добавьте post-receive хук
3. Делайте push в production ветку

Подробности в файле `DEPLOYMENT.md`.