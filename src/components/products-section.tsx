import { Card, CardContent } from "./ui/card";
import { Badge } from "./ui/badge";
import { ImageWithFallback } from "./figma/ImageWithFallback";
import { DoorOpen, Shield, Flame, Stethoscope, Radiation } from "lucide-react";

const products = [
  {
    title: "Двери для палат",
    description: "Специальные двери для палат интенсивной терапии, реанимации и обычных палат",
    features: ["Антибактериальное покрытие", "Простота дезинфекции", "Бесшумная работа"],
    icon: DoorOpen,
    image: "/src/assets/images/dorren_medical_door_palata_sm.jpg"
  },
  {
    title: "Двери для кабинетов",
    description: "Двери для врачебных кабинетов, процедурных и диагностических помещений",
    features: ["Звукоизоляция", "Стойкость к химии", "Гигиеничность"],
    icon: Stethoscope,
    image: "/src/assets/images/dorren_medical_door_cabinet_sm.jpg"
  },
  {
    title: "Рентгенозащитные двери",
    description: "Двери с защитой от рентгеновского излучения для диагностических кабинетов",
    features: ["Свинцовый эквивалент до 4мм", "Автоматическое управление", "Сигнализация"],
    icon: Radiation,
    image: "/src/assets/images/dorren_medical_door_rentgen_sm.jpg"
  },
  {
    title: "Противопожарные двери",
    description: "Огнестойкие двери для обеспечения пожарной безопасности медучреждений",
    features: ["Предел огнестойкости EI-60", "Самозакрывание", "Дымонепроницаемость"],
    icon: Flame,
    image: "/src/assets/images/dorren_medical_door_fire_sm.jpg"
  }
];

export function ProductsSection() {
  const handleConsultationClick = () => {
    const form = document.querySelector('#consultation-form');
    if (form) {
      form.scrollIntoView({ behavior: 'smooth' });
    }
  };

  return (
    <section id="products" className="py-20 bg-white">
      <div className="container mx-auto px-4">
        <div className="text-center mb-16">
          <h2 className="text-4xl font-light text-black mb-4">
            Наша продукция
          </h2>
          <p className="text-xl text-gray-600 max-w-3xl mx-auto">
            Полный спектр медицинских дверей для любых задач. 
            Все изделия соответствуют медицинским стандартам и нормам безопасности.
          </p>
        </div>

        <div className="grid md:grid-cols-2 lg:grid-cols-4 gap-8">
          {products.map((product, index) => {
            const IconComponent = product.icon;
            return (
              <Card key={index} className="overflow-hidden hover:shadow-lg transition-shadow border-gray-100">
                <div className="relative h-48 overflow-hidden">
                  <ImageWithFallback
                    src={product.image}
                    alt={product.title}
                    className="w-full h-full object-cover"
                  />
                  <div className="absolute top-4 left-4">
                    <div className="w-12 h-12 bg-white/90 backdrop-blur-sm rounded-lg flex items-center justify-center">
                      <IconComponent className="h-6 w-6 text-cyan-400" />
                    </div>
                  </div>
                </div>
                
                <CardContent className="p-6">
                  <h3 className="text-xl font-medium text-black mb-3">
                    {product.title}
                  </h3>
                  <p className="text-gray-600 mb-4 text-sm leading-relaxed">
                    {product.description}
                  </p>
                  
                  <div className="space-y-2">
                    {product.features.map((feature, idx) => (
                      <Badge 
                        key={idx} 
                        variant="secondary" 
                        className="mr-2 mb-1 bg-gray-100 text-gray-700 hover:bg-gray-200"
                      >
                        {feature}
                      </Badge>
                    ))}
                  </div>
                </CardContent>
              </Card>
            );
          })}
        </div>

        <div className="text-center mt-12">
          <p className="text-gray-600 mb-6">
            Нужна консультация по выбору дверей для вашего проекта?
          </p>
          <button
            onClick={handleConsultationClick}
            className="bg-cyan-400 hover:bg-cyan-500 text-white px-8 py-3 rounded-lg transition-colors"
          >
            Получить техническое предложение
          </button>
        </div>
      </div>
    </section>
  );
}