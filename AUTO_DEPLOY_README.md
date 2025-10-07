# 🚀 Автоматическое развертывание на VPS

Три скрипта для автоматического развертывания сайта медицинских дверей на VPS сервер.

## Скрипты

### 1. `deploy-to-vps.sh` - Самый простой способ
**Использование:** `./deploy-to-vps.sh your-server-ip`

```bash
# Пример использования
./deploy-to-vps.sh 192.168.1.100
./deploy-to-vps.sh your-vps.example.com
```

**Что делает:**
- ✅ Собирает проект (`npm run build`)
- ✅ Загружает файлы на сервер
- ✅ Настраивает Nginx автоматически
- ✅ Устанавливает правильные права доступа
- ✅ Перезагружает веб-сервер

**Время выполнения:** ~2-3 минуты

---

### 2. `auto-deploy.sh` - Умный автоматический скрипт
**Использование:** `./auto-deploy.sh root@your-server-ip`

```bash
# Пример использования
./auto-deploy.sh root@192.168.1.100
./auto-deploy.sh user@your-vps.com
```

**Особенности:**
- ✅ Автоматически определяет окружение (локальный/сервер)
- ✅ Создает архив для быстрой передачи
- ✅ Настраивает сервер полностью автоматически
- ✅ Показывает прогресс выполнения
- ✅ Очищает временные файлы

**Время выполнения:** ~3-5 минут

---

### 3. `server-setup.sh` - Только настройка сервера
**Использование на сервере:** `curl -s https://example.com/server-setup.sh | bash`

Или загрузите файл на сервер и выполните:
```bash
chmod +x server-setup.sh
./server-setup.sh
```

**Что делает:**
- ✅ Устанавливает Nginx, Node.js
- ✅ Создает директорию для сайта
- ✅ Настраивает оптимальную конфигурацию Nginx
- ✅ Создает временный index.html для проверки
- ✅ Показывает IP адрес сервера

**Время выполнения:** ~5-7 минут

---

## Быстрый старт (3 шага)

### Шаг 1: Подготовьте сервер
```bash
# На сервере выполните:
curl -s https://raw.githubusercontent.com/your-repo/server-setup.sh | bash
# Или используйте auto-deploy.sh
```

### Шаг 2: Разверните сайт
```bash
# На локальной машине:
./deploy-to-vps.sh your-server-ip
```

### Шаг 3: Проверьте работу
Откройте браузер: `http://your-server-ip`

---

## Сравнение скриптов

| Функция | deploy-to-vps.sh | auto-deploy.sh | server-setup.sh |
|---------|-----------------|----------------|------------------|
| Простота использования | ⭐⭐⭐ | ⭐⭐ | ⭐⭐ |
| Автоматизация | ⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐ |
| Скорость | ⭐⭐⭐ | ⭐⭐ | ⭐ |
| Функциональность | ⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐ |

**Рекомендация:** Начните с `deploy-to-vps.sh` - самый простой и быстрый способ.

---

## Устранение проблем

### Ошибка сборки в Windows/WSL
Если получили ошибку `@rollup/rollup-linux-x64-gnu`:

```bash
# Запустите скрипт исправления сборки
chmod +x fix-build.sh
./fix-build.sh

# Или вручную:
rm -rf node_modules package-lock.json
npm install
npm run build
```

### Ошибка "Connection refused"
```bash
# Проверьте доступность сервера
ping your-server-ip

# Проверьте SSH доступ
ssh root@your-server-ip "echo 'SSH работает'"
```

### Ошибка "Permission denied"
```bash
# Проверьте SSH ключи или используйте пароль
ssh -o PasswordAuthentication=yes root@your-server-ip
```

### Ошибка "nginx: [emerg]"
```bash
# Проверьте конфигурацию
ssh root@your-server-ip "sudo nginx -t"

# Просмотрите логи ошибок
ssh root@your-server-ip "sudo tail -f /var/log/nginx/medical-doors_error.log"
```

### Сайт не загружается
```bash
# Проверьте статус nginx
ssh root@your-server-ip "sudo systemctl status nginx"

# Проверьте файлы сайта
ssh root@your-server-ip "ls -la /var/www/medical-doors/dist/"

# Тест HTTP запроса
curl -I http://your-server-ip
```

---

## Мониторинг после развертывания

```bash
# Статус веб-сервера
ssh root@your-server-ip "sudo systemctl status nginx"

# Логи доступа
ssh root@your-server-ip "sudo tail -f /var/log/nginx/medical-doors_access.log"

# Использование ресурсов
ssh root@your-server-ip "htop"

# Перезапуск сервера
ssh root@your-server-ip "sudo systemctl restart nginx"
```

---

## Дополнительные настройки

### SSL сертификат (после развертывания)
```bash
ssh root@your-server-ip "sudo apt install certbot python3-certbot-nginx -y"
ssh root@your-server-ip "sudo certbot --nginx -d your-domain.com"
```

### Домены
Отредактируйте конфигурацию Nginx:
```bash
ssh root@your-server-ip "sudo nano /etc/nginx/sites-available/medical-doors"
# Измените server_name _; на server_name your-domain.com;
ssh root@your-server-ip "sudo systemctl reload nginx"
```

---

## Поддержка

Если возникнут проблемы:
1. Проверьте логи: `sudo tail -f /var/log/nginx/medical-doors_error.log`
2. Убедитесь, что сервер доступен: `ping your-server-ip`
3. Проверьте статус сервисов: `sudo systemctl status nginx`

**Время развертывания:** 2-7 минут в зависимости от выбранного скрипта.