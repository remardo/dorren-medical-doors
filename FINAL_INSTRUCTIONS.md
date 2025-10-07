# 🚀 Финальная инструкция по использованию проекта медицинских дверей

## Репозиторий на GitHub

**Ссылка на репозиторий:** `https://github.com/remardo/dorren-medical-doors`

## Быстрый старт

### Шаг 1: Скачайте проект
```bash
# Клонируйте репозиторий
git clone https://github.com/remardo/dorren-medical-doors.git
cd dorren-medical-doors

# Установите зависимости
npm install

# Соберите проект
npm run build
```

### Шаг 2: Подготовьте изображения
```bash
# В Linux/Mac:
./copy-images.sh

# В Windows:
copy-images.bat
```

### Шаг 3: Разверните на сервере
```bash
# В Linux/Mac:
./upload-to-server.sh

# Альтернатива:
curl -s https://raw.githubusercontent.com/remardo/dorren-medical-doors/main/setup-http-only.sh | bash
```

## Структура проекта

```
dorren-medical-doors/
├── 📁 Скрипты развертывания
│   ├── deploy-to-vps.sh          # Основной скрипт развертывания
│   ├── setup-http-only.sh        # Настройка HTTP без SSL
│   ├── manual-ssl-fix.sh         # Ручная настройка SSL
│   ├── upload-to-server.sh       # Загрузка файлов на сервер
│   ├── copy-images.sh           # Копирование изображений (Linux)
│   └── copy-images.bat          # Копирование изображений (Windows)
│
├── 📁 Конфигурации
│   ├── nginx.conf               # Базовая конфигурация nginx
│   ├── nginx-ssl.conf           # Конфигурация с SSL
│   └── nginx-https-fix.sh       # Исправление HTTPS конфигурации
│
├── 📁 Документация
│   ├── DEPLOYMENT.md            # Подробная инструкция развертывания
│   ├── STEP_BY_STEP_VPS_DEPLOY.md # Пошаговая инструкция
│   ├── SSL_SETUP_README.md      # Инструкция по SSL
│   ├── WINDOWS_DEPLOY_README.md # Инструкция для Windows
│   └── README.md                # Главная страница проекта
│
└── 📁 Исходный код
    ├── src/                     # React приложение
    ├── public/                  # Статические файлы
    └── dist/                    # Собранные файлы
```

## Использование скриптов напрямую

### Развертывание сервера
```bash
# Настройка сервера с нуля
curl -s https://raw.githubusercontent.com/remardo/dorren-medical-doors/main/wsl-server-fix.sh | bash

# Настройка HTTP сайта
curl -s https://raw.githubusercontent.com/remardo/dorren-medical-doors/main/setup-http-only.sh | bash

# Настройка SSL
curl -s https://raw.githubusercontent.com/remardo/dorren-medical-doors/main/manual-ssl-fix.sh | bash
```

### Диагностика проблем
```bash
# Диагностика сервера
curl -s https://raw.githubusercontent.com/remardo/dorren-medical-doors/main/final-https-check.sh | bash

# Проверка логов
curl -s https://raw.githubusercontent.com/remardo/dorren-medical-doors/main/show-logs.sh | bash
```

## Текущий статус проекта

### ✅ Что работает:
- 🚀 Полностью автоматизированная система развертывания
- 🔒 Поддержка SSL сертификатов Let's Encrypt
- 🖼️ Исправленные пути к изображениям
- 📱 Адаптивный дизайн для всех устройств
- ⚡ Оптимизированная производительность
- 🔧 Кроссплатформенные скрипты (Linux/Windows/WSL)

### 🌐 Рабочий сайт:
**https://meddoors.dorren.ru** - Сайт медицинских дверей с полной функциональностью

## Поддержка и развитие

### Если возникнут проблемы:
1. Проверьте логи: `sudo tail -f /var/log/nginx/meddoors_error.log`
2. Используйте диагностику: `./final-https-check.sh`
3. Читайте документацию в папке проекта

### Для обновлений:
```bash
# Получите последние изменения
git pull origin main

# Соберите обновленный проект
npm run build

# Загрузите изменения на сервер
./upload-to-server.sh
```

## Результат

Проект **"Медицинские двери"** успешно развернут на VPS с:
- ✅ Полноценным сайтом медицинских дверей
- ✅ SSL сертификатами и HTTPS
- ✅ Оптимизированным nginx сервером
- ✅ Автоматическим развертыванием
- ✅ Кроссплатформенной поддержкой

**Поздравляем! Ваш сайт готов к использованию! 🎉**