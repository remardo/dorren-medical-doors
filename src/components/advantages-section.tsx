import { Card, CardContent } from "./ui/card";
import { CheckCircle, Clock, Users, MapPin, Settings, HeadphonesIcon } from "lucide-react";

const advantages = [
  {
    icon: CheckCircle,
    title: "Полное соответствие ГОСТам",
    description: "Все двери сертифицированы и соответствуют медицинским стандартам РФ"
  },
  {
    icon: Clock,
    title: "Сроки от 35 дней",
    description: "Быстрое производство и установка под ключ по всей России"
  },
  {
    icon: Users,
    title: "1500+ реализованных проектов",
    description: "25 лет успешной работы с медицинскими учреждениями"
  },
  {
    icon: MapPin,
    title: "Поставки по России и СНГ",
    description: "Собственная логистика и монтажные бригады в регионах"
  },
  {
    icon: Settings,
    title: "Собственное производство",
    description: "Контроль качества на всех этапах от материалов до установки"
  },
  {
    icon: HeadphonesIcon,
    title: "Гарантия 3 года",
    description: "Сервисное обслуживание и ремонт в течение всего срока эксплуатации"
  }
];

export function AdvantagesSection() {
  return (
    <section id="advantages" className="py-20 bg-gray-50">
      <div className="container mx-auto px-4">
        <div className="text-center mb-16">
          <h2 className="text-4xl font-light text-black mb-4">
            Почему выбирают нас
          </h2>
          <p className="text-xl text-gray-600 max-w-3xl mx-auto">
            Мы обеспечиваем полный цикл работ — от проектирования до установки и сервиса
          </p>
        </div>

        <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-8">
          {advantages.map((advantage, index) => {
            const IconComponent = advantage.icon;
            return (
              <Card key={index} className="border-0 shadow-sm hover:shadow-md transition-shadow bg-white">
                <CardContent className="p-8 text-center">
                  <div className="w-16 h-16 bg-cyan-50 rounded-full flex items-center justify-center mx-auto mb-6">
                    <IconComponent className="h-8 w-8 text-cyan-400" />
                  </div>
                  <h3 className="text-xl font-medium text-black mb-4">
                    {advantage.title}
                  </h3>
                  <p className="text-gray-600 leading-relaxed">
                    {advantage.description}
                  </p>
                </CardContent>
              </Card>
            );
          })}
        </div>

        {/* Stats */}
        <div className="mt-16 bg-black rounded-2xl p-8 text-white">
          <div className="grid md:grid-cols-4 gap-8 text-center">
            <div>
              <div className="text-3xl font-light text-cyan-400 mb-2">1500+</div>
              <div className="text-gray-300">Завершенных проектов</div>
            </div>
            <div>
              <div className="text-3xl font-light text-cyan-400 mb-2">25</div>
              <div className="text-gray-300">Лет на рынке</div>
            </div>
            <div>
              <div className="text-3xl font-light text-cyan-400 mb-2">50+</div>
              <div className="text-gray-300">Регионов поставок</div>
            </div>
            <div>
              <div className="text-3xl font-light text-cyan-400 mb-2">Под ключ</div>
              <div className="text-gray-300">Сну что дача объекта </div>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}