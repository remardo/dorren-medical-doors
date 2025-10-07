/**
 * Утилита для получения Chat ID
 *
 * Чтобы получить Chat ID:
 * 1. Замените YOUR_BOT_TOKEN на токен вашего бота
 * 2. Откройте браузер и перейдите по ссылке ниже
 * 3. Найдите в ответе поле "chat":{"id":
 */

export const getChatIdInstructions = {
  title: 'Получение Chat ID для Telegram бота',
  steps: [
    '1. Создайте бота через @BotFather и получите токен',
    '2. Добавьте бота в нужный чат (группу или личный чат)',
    '3. Отправьте любое сообщение в этот чат',
    '4. Замените YOUR_BOT_TOKEN на токен вашего бота в ссылке ниже:',
    '5. Откройте ссылку в браузере и найдите Chat ID в ответе JSON'
  ],
  apiUrl: 'https://api.telegram.org/botYOUR_BOT_TOKEN/getUpdates',
  alternativeBots: [
    '@userinfobot - перешлите ему сообщение из нужного чата',
    '@getmyid_bot - добавьте в чат и отправьте /start'
  ],
  note: 'Chat ID может быть отрицательным числом для групп - это нормально!'
};

// Для отображения инструкций в консоли разработки
export const logChatIdInstructions = () => {
  console.log('📱 Инструкция по получению Chat ID для Telegram:');
  console.log('🔗 Ссылка для API:', getChatIdInstructions.apiUrl);
  console.log('📋 Шаги:', getChatIdInstructions.steps);
  console.log('🤖 Альтернативные боты:', getChatIdInstructions.alternativeBots);
  console.log('⚠️  Важно:', getChatIdInstructions.note);
};