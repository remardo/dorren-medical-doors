import { Card, CardContent } from "./ui/card";
import { Badge } from "./ui/badge";
import { ImageWithFallback } from "./figma/ImageWithFallback";
import { MapPin, Calendar, Building } from "lucide-react";

const projects = [
  {
    name: "<Клиника высоких технологий Белоостров>",
    location: "Санкт-Петербург",
    year: "2024",
    doors: "200 дверей",
    types: ["Палаты", "Кабинеты", "Противопожарные"],
    image: "/assets/images/dorren_project_beloostrov.jpg"
  },
  {
    name: "Больница имени Н. А. Семашко",
    location: "Крым",
    year: "2020",
    doors: "2500 дверей",
    types: ["Рентгенозащитные", "Кабинеты","Автоматические" ],
    image: "/assets/images/dorren_project_semashko.jpg"
  },
  {
    name: "12 инфекционных больниц в Казахстане",
    location: "Казахстан",
    year: "2020",
    doors: "4000 дверей",
    types: ["Палаты", "Операционные", "Реанимация"],
    image: "/assets/images/dorren_project_kazahstan.jpg"
  },
  {
    name: "Клиники МедСи",
    location: "Москва",
    year: "2020",
    doors: "1100 дверей",
    types: ["Рентгенозащитные", "Палаты", "Противопожарные"],
    image: "/assets/images/dorren_project_medsi.jpg"
  }
];

export function ProjectsSection() {
  return (
    <section id="projects" className="py-20 bg-gray-50">
      <div className="container mx-auto px-4">
        <div className="text-center mb-16">
          <h2 className="text-4xl font-light text-black mb-4">
            Реализованные проекты
          </h2>
          <p className="text-xl text-gray-600 max-w-3xl mx-auto">
            Мы гордимся доверием ведущих медицинских учреждений России
          </p>
        </div>

        <div className="grid md:grid-cols-2 gap-8 mb-12">
          {projects.map((project, index) => (
            <Card key={index} className="overflow-hidden hover:shadow-lg transition-shadow border-gray-100 bg-white">
              <div className="relative h-48 overflow-hidden">
                <ImageWithFallback
                  src={project.image}
                  alt={project.name}
                  className="w-full h-full object-cover"
                />
                <div className="absolute top-4 right-4">
                  <Badge className="bg-white/90 text-black border-0">
                    {project.doors}
                  </Badge>
                </div>
              </div>
              
              <CardContent className="p-6">
                <h3 className="text-xl font-medium text-black mb-3">
                  {project.name}
                </h3>
                
                <div className="flex items-center space-x-4 text-sm text-gray-600 mb-4">
                  <div className="flex items-center space-x-1">
                    <MapPin className="h-4 w-4" />
                    <span>{project.location}</span>
                  </div>
                  <div className="flex items-center space-x-1">
                    <Calendar className="h-4 w-4" />
                    <span>{project.year}</span>
                  </div>
                </div>
                
                <div className="space-y-2">
                  {project.types.map((type, idx) => (
                    <Badge 
                      key={idx} 
                      variant="secondary" 
                      className="mr-2 mb-1 bg-cyan-50 text-cyan-700 hover:bg-cyan-100"
                    >
                      {type}
                    </Badge>
                  ))}
                </div>
              </CardContent>
            </Card>
          ))}
        </div>

        {/* Client logos placeholder */}
        <div className="bg-white rounded-2xl p-8">
          <h3 className="text-2xl font-light text-black text-center mb-8">
            Нам доверяют
          </h3>
          <div className="grid grid-cols-2 md:grid-cols-4 gap-8 items-center opacity-60">
            <div className="text-center">
              <Building className="h-12 w-12 mx-auto text-gray-400 mb-2" />
              <div className="text-sm text-gray-500">Городские больницы</div>
            </div>
            <div className="text-center">
              <Building className="h-12 w-12 mx-auto text-gray-400 mb-2" />
              <div className="text-sm text-gray-500">Частные клиники</div>
            </div>
            <div className="text-center">
              <Building className="h-12 w-12 mx-auto text-gray-400 mb-2" />
              <div className="text-sm text-gray-500">Медцентры</div>
            </div>
            <div className="text-center">
              <Building className="h-12 w-12 mx-auto text-gray-400 mb-2" />
              <div className="text-sm text-gray-500">Диагностические центры</div>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}