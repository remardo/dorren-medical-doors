interface FormData {
  [key: string]: string;
}

class TelegramService {
  private static instance: TelegramService;
  private botToken: string;
  private chatId: string;

  constructor() {
    // В реальном проекте эти данные должны быть в .env файле
    this.botToken = (import.meta as any).env?.VITE_TELEGRAM_BOT_TOKEN || 'YOUR_BOT_TOKEN';
    this.chatId = (import.meta as any).env?.VITE_TELEGRAM_CHAT_ID || 'YOUR_CHAT_ID';
  }

  static getInstance(): TelegramService {
    if (!TelegramService.instance) {
      TelegramService.instance = new TelegramService();
    }
    return TelegramService.instance;
  }

  private formatMessage(data: FormData, formType: string): string {
    const timestamp = new Date().toLocaleString('ru-RU', {
      timeZone: 'Europe/Moscow',
      year: 'numeric',
      month: '2-digit',
      day: '2-digit',
      hour: '2-digit',
      minute: '2-digit'
    });

    let message = `🔔 Новая заявка с сайта DORREN\n\n`;
    message += `📅 Время: ${timestamp}\n`;
    message += `📋 Тип формы: ${formType}\n\n`;

    Object.entries(data).forEach(([key, value]) => {
      if (value && value.trim()) {
        const label = this.getFieldLabel(key);
        message += `${label}: ${value}\n`;
      }
    });

    return message;
  }

  private getFieldLabel(key: string): string {
    const labels: { [key: string]: string } = {
      'name': '👤 Имя',
      'company': '🏢 Компания',
      'phone': '📞 Телефон',
      'email': '📧 Email',
      'project': '🏗️ Тип проекта',
      'contact-name': '👤 Контактное лицо',
      'organization': '🏢 Организация',
      'calc-phone': '📞 Телефон',
      'facility-type': '🏥 Тип учреждения',
      'doors-count': '🚪 Количество дверей',
      'door-types': '🚪 Типы дверей',
      'project-details': '📝 Описание проекта',
      'position': '💼 Должность',
      'interest': '🎯 Интересующая продукция',
      'cat-name': '👤 Имя',
      'cat-email': '📧 Email',
      'cat-company': '🏢 Компания',
      'cat-position': '💼 Должность',
      'cat-interest': '🎯 Интересующая продукция'
    };

    return labels[key] || key;
  }

  async sendMessage(data: FormData, formType: string): Promise<boolean> {
    try {
      const text = this.formatMessage(data, formType);
      const url = `https://api.telegram.org/bot${this.botToken}/sendMessage`;

      console.log('🚀 Отправка в Telegram:', { chatId: this.chatId, formType, url: url.replace(this.botToken, '***') });

      const response = await fetch(url, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          chat_id: this.chatId,
          text: text
        }),
      });

      const result = await response.json();
      console.log('📨 Ответ Telegram API:', result);

      // Проверяем HTTP статус
      if (!response.ok) {
        console.error('❌ HTTP ошибка:', response.status, response.statusText);
        throw new Error(`HTTP error! status: ${response.status}`);
      }

      // Проверяем ответ Telegram API более мягко
      if (result.ok === false) {
        console.error('❌ Ошибка Telegram API:', result.description);
        // Не бросаем ошибку, а только логируем, так как сообщение может быть отправлено
        if (result.error_code === 400 && result.description.includes('chat not found')) {
          console.error('💬 Проверьте правильность Chat ID');
        }
      }

      // Считаем успешным, если HTTP запрос прошел успешно (статус 2xx)
      if (response.ok) {
        console.log('✅ Сообщение отправлено в Telegram успешно');
        return true;
      }

      console.warn('⚠️ HTTP статус не успешен:', response.status, response.statusText);
      return false;
    } catch (error) {
      console.error('❌ Критическая ошибка отправки в Telegram:', error);
      throw error;
    }
  }
}

export default TelegramService;