
  # Landing Page for Medical Doors (Community)

  This is a code bundle for Landing Page for Medical Doors (Community). The original project is available at https://www.figma.com/design/aYyzm9tFSKKRxNutl8Y8gq/Landing-Page-for-Medical-Doors--Community-.

  ## Running the code

  Run `npm i` to install the dependencies.

  Run `npm run dev` to start the development server.

  ## Настройка отправки форм в Telegram

  Проект включает функционал отправки данных из форм в Telegram.

  📖 **Подробная инструкция:** См. файл [`TELEGRAM_SETUP.md`](TELEGRAM_SETUP.md) для полной настройки

  ### Краткая инструкция:

  1. **Создайте бота** через [@BotFather](https://t.me/botfather) - получите токен
  2. **Получите Chat ID** - см. способы в [`TELEGRAM_SETUP.md`](TELEGRAM_SETUP.md)
  3. **Настройте `.env`** файл с токеном и Chat ID
  4. **Готово!** Все формы теперь отправляют данные в Telegram

  ### 3. Настройка переменных окружения

  1. Скопируйте файл `.env.example` в `.env`:
     ```bash
     cp .env.example .env
     ```

  2. Откройте файл `.env` и добавьте ваши данные:
     ```env
     VITE_TELEGRAM_BOT_TOKEN=your_bot_token_here
     VITE_TELEGRAM_CHAT_ID=your_chat_id_here
     ```

  ### 4. Функциональность

  После настройки все формы на сайте будут отправлять данные в ваш Telegram чат:

  - **Форма консультации** (Hero Section) - основная форма в шапке сайта
  - **Форма калькулятора** (Calculator Section) - форма расчета стоимости проекта
  - **Форма каталога** (Catalog Section) - форма заказа каталога продукции

  Каждое сообщение содержит:
  - Временную метку
  - Тип формы
  - Все заполненные поля формы
  - Помечается соответствующими эмодзи для удобства

  ### 5. Возможные проблемы

  Если сообщения не приходят:
  - Убедитесь, что бот добавлен в нужный чат
  - Проверьте правильность токена и Chat ID
  - Убедитесь, что в файле `.env` нет лишних пробелов
  - Проверьте консоль браузера на наличие ошибок
  