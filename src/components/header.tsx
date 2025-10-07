import { Button } from "./ui/button";
import { Phone, Mail } from "lucide-react";

export function Header() {
  const handleConsultationClick = () => {
    const form = document.querySelector('#consultation-form');
    if (form) {
      form.scrollIntoView({ behavior: 'smooth' });
    }
  };

  return (
    <header className="bg-white border-b border-gray-100 sticky top-0 z-50">
      <div className="container mx-auto px-4 py-4">
        <div className="flex items-center justify-between">
          {/* Logo */}
          <div className="flex items-center space-x-2">
            <div className="text-2xl font-light tracking-wider text-black">
              DORREN
            </div>
          </div>

          {/* Navigation */}
          <nav className="hidden md:flex items-center space-x-8">
            <a href="#products" className="text-gray-600 hover:text-black transition-colors">
              Продукция
            </a>
            <a href="#advantages" className="text-gray-600 hover:text-black transition-colors">
              Преимущества
            </a>
            <a href="#projects" className="text-gray-600 hover:text-black transition-colors">
              Проекты
            </a>
            <a href="#contacts" className="text-gray-600 hover:text-black transition-colors">
              Контакты
            </a>
          </nav>

          {/* Contact Info */}
          <div className="hidden lg:flex items-center space-x-6">
            <div className="flex items-center space-x-2 text-sm">
              <Phone className="h-4 w-4 text-cyan-400" />
              <span className="text-gray-600">+7 (495) 123-45-67</span>
            </div>
            <div className="flex items-center space-x-2 text-sm">
              <Mail className="h-4 w-4 text-cyan-400" />
              <span className="text-gray-600">info@dorren.ru</span>
            </div>
          </div>

          {/* CTA Button */}
          <Button 
            onClick={handleConsultationClick}
            className="bg-black hover:bg-gray-800 text-white hidden md:flex"
          >
            Получить консультацию
          </Button>
        </div>
      </div>
    </header>
  );
}