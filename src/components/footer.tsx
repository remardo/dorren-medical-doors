import { Phone, Mail, MapPin, Clock } from "lucide-react";

export function Footer() {
  return (
    <footer id="contacts" className="bg-black text-white py-16">
      <div className="container mx-auto px-4">
        <div className="grid md:grid-cols-2 lg:grid-cols-4 gap-8">
          {/* Company Info */}
          <div>
            <div className="text-2xl font-light tracking-wider mb-6">
              DORREN
            </div>
            <p className="text-gray-400 mb-6 leading-relaxed">
              Производство и установка медицинских дверей под ключ. 
              15 лет успешной работы на рынке.
            </p>
            <div className="text-cyan-400 text-sm">
              ООО "Доррен"<br />
              ИНН: 7712345678<br />
              ОГРН: 1127712345678
            </div>
          </div>

          {/* Contact Info */}
          <div>
            <h4 className="text-lg font-medium mb-6">Контакты</h4>
            <div className="space-y-4">
              <div className="flex items-center space-x-3">
                <Phone className="h-5 w-5 text-cyan-400 flex-shrink-0" />
                <div>
                  <div className="text-white">+7 (495) 123-45-67</div>
                  <div className="text-gray-400 text-sm">Отдел продаж</div>
                </div>
              </div>
              
              <div className="flex items-center space-x-3">
                <Mail className="h-5 w-5 text-cyan-400 flex-shrink-0" />
                <div>
                  <div className="text-white">info@dorren.ru</div>
                  <div className="text-gray-400 text-sm">Общие вопросы</div>
                </div>
              </div>
              
              <div className="flex items-start space-x-3">
                <MapPin className="h-5 w-5 text-cyan-400 flex-shrink-0 mt-0.5" />
                <div>
                  <div className="text-white">Москва, ул. Промышленная, 15</div>
                  <div className="text-gray-400 text-sm">Офис и производство</div>
                </div>
              </div>
            </div>
          </div>

          {/* Working Hours */}
          <div>
            <h4 className="text-lg font-medium mb-6">Режим работы</h4>
            <div className="space-y-3">
              <div className="flex items-center space-x-3">
                <Clock className="h-5 w-5 text-cyan-400 flex-shrink-0" />
                <div>
                  <div className="text-white">Пн-Пт: 9:00 - 18:00</div>
                  <div className="text-gray-400 text-sm">Офис</div>
                </div>
              </div>
              
              <div className="flex items-center space-x-3">
                <Phone className="h-5 w-5 text-cyan-400 flex-shrink-0" />
                <div>
                  <div className="text-white">24/7</div>
                  <div className="text-gray-400 text-sm">Техподдержка</div>
                </div>
              </div>
            </div>
            
            <div className="mt-6 pt-6 border-t border-gray-800">
              <div className="text-sm text-gray-400">
                <div>Производство:</div>
                <div className="text-white">Пн-Пт: 8:00 - 20:00</div>
                <div className="text-white">Сб: 9:00 - 15:00</div>
              </div>
            </div>
          </div>

          {/* Services */}
          <div>
            <h4 className="text-lg font-medium mb-6">Услуги</h4>
            <ul className="space-y-2 text-gray-400">
              <li className="hover:text-white transition-colors cursor-pointer">
                Двери для палат
              </li>
              <li className="hover:text-white transition-colors cursor-pointer">
                Двери для кабинетов
              </li>
              <li className="hover:text-white transition-colors cursor-pointer">
                Рентгенозащитные двери
              </li>
              <li className="hover:text-white transition-colors cursor-pointer">
                Противопожарные двери
              </li>
              <li className="hover:text-white transition-colors cursor-pointer">
                Проектирование
              </li>
              <li className="hover:text-white transition-colors cursor-pointer">
                Монтаж и установка
              </li>
              <li className="hover:text-white transition-colors cursor-pointer">
                Сервисное обслуживание
              </li>
            </ul>
          </div>
        </div>

        {/* Bottom */}
        <div className="border-t border-gray-800 mt-12 pt-8">
          <div className="flex flex-col md:flex-row justify-between items-center space-y-4 md:space-y-0">
            <div className="text-gray-400 text-sm">
              © 2024 DORREN. Все права защищены.
            </div>
            <div className="flex space-x-6 text-sm text-gray-400">
              <a href="#" className="hover:text-white transition-colors">
                Политика конфиденциальности
              </a>
              <a href="#" className="hover:text-white transition-colors">
                Пользовательское соглашение
              </a>
            </div>
          </div>
        </div>
      </div>
    </footer>
  );
}