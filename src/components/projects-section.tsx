import { Card, CardContent } from "./ui/card";
import { Badge } from "./ui/badge";
import { ImageWithFallback } from "./figma/ImageWithFallback";
import { MapPin, Calendar, Building } from "lucide-react";

const projects = [
  {
    name: "Городская больница №15",
    location: "Москва",
    year: "2024",
    doors: "120 дверей",
    types: ["Палаты", "Кабинеты", "Противопожарные"],
    image: "https://images.unsplash.com/photo-1519494140681-8b17d830a3e9?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxtZWRpY2FsJTIwZG9vcnMlMjBob3NwaXRhbHxlbnwxfHx8fDE3NTc2OTA5OTB8MA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral"
  },
  {
    name: "Диагностический центр \"Здоровье\"",
    location: "Санкт-Петербург",
    year: "2024",
    doors: "45 дверей",
    types: ["Рентгенозащитные", "Кабинеты"],
    image: "https://images.unsplash.com/photo-1631507623121-eaaba8d4e7dc?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxtb2Rlcm4lMjBjbGluaWMlMjBlbnRyYW5jZXxlbnwxfHx8fDE3NTc2ODcwMzd8MA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral"
  },
  {
    name: "Перинатальный центр",
    location: "Екатеринбург",
    year: "2023",
    doors: "200 дверей",
    types: ["Палаты", "Операционные", "Реанимация"],
    image: "https://images.unsplash.com/photo-1593376063528-72e70ddcb2c3?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxob3NwaXRhbCUyMGNvcnJpZG9yJTIwZG9vcnN8ZW58MXx8fHwxNzU3NjkwOTkxfDA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral"
  },
  {
    name: "Онкологический центр",
    location: "Новосибирск",
    year: "2023",
    doors: "80 дверей",
    types: ["Рентгенозащитные", "Палаты", "Противопожарные"],
    image: "https://images.unsplash.com/photo-1711343777918-6d395c16e37f?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxtZWRpY2FsJTIwZmFjaWxpdHklMjBpbnRlcmlvcnxlbnwxfHx8fDE3NTc2ODc1Mjl8MA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral"
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