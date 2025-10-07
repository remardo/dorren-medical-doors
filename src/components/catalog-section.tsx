import React, { useState } from "react";
import { Card, CardContent } from "./ui/card";
import { Button } from "./ui/button";
import { Input } from "./ui/input";
import { Label } from "./ui/label";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "./ui/select";
import { Checkbox } from "./ui/checkbox";
import { BookOpen, Download, FileText, Loader2 } from "lucide-react";
import TelegramService from "../services/telegramService";

export function CatalogSection() {
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [submitError, setSubmitError] = useState<string | null>(null);
  const [submitSuccess, setSubmitSuccess] = useState(false);

  const handleFormSubmit = async (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    setIsSubmitting(true);
    setSubmitError(null);
    setSubmitSuccess(false);

    const formData = new FormData(e.currentTarget);

    // Обрабатываем чекбоксы отдельно
    const catInterests = formData.getAll('cat-interest') as string[];
    const data: { [key: string]: string } = {};

    // Копируем все данные формы
    for (let [key, value] of formData.entries()) {
      if (key !== 'cat-interest') {
        data[key] = value as string;
      }
    }

    // Обрабатываем чекбоксы интересующей продукции
    if (catInterests.length > 0) {
      const interestLabels: { [key: string]: string } = {
        'all': 'Весь каталог',
        'cabinet': 'Двери для кабинетов',
        'ward': 'Двери для палат',
        'xray': 'Рентгенозащитные',
        'fire': 'Противопожарные',
        'surgery': 'Двери для операционных'
      };

      const selectedInterests = catInterests.map(interest => interestLabels[interest] || interest);
      data['cat-interest'] = selectedInterests.join(', ');
    }

    try {
      const telegramService = TelegramService.getInstance();
      await telegramService.sendMessage(data, 'Форма заказа каталога');

      setSubmitSuccess(true);
      e.currentTarget?.reset();

      // Скрываем сообщение об успехе через 5 секунд
      setTimeout(() => {
        setSubmitSuccess(false);
      }, 5000);

    } catch (error) {
      console.error('Ошибка отправки формы:', error);
      setSubmitError('Произошла ошибка при отправке формы. Пожалуйста, попробуйте еще раз.');
    } finally {
      setIsSubmitting(false);
    }
  };
  return (
    <section className="py-20 bg-white">
      <div className="container mx-auto px-4">
        <div className="grid lg:grid-cols-2 gap-12 items-center">
          {/* Left Content */}
          <div>
            <div className="w-16 h-16 bg-cyan-50 rounded-full flex items-center justify-center mb-6">
              <BookOpen className="h-8 w-8 text-cyan-400" />
            </div>
            
            <h2 className="text-4xl font-light text-black mb-6">
              Каталог медицинских дверей
            </h2>
            
            <p className="text-xl text-gray-600 mb-8 leading-relaxed">
              Скачайте подробный каталог с техническими характеристиками, 
              сертификатами и примерами реализованных проектов.
            </p>
            
            <div className="space-y-6">
              <div className="flex items-start space-x-4">
                <div className="w-10 h-10 bg-cyan-50 rounded-lg flex items-center justify-center flex-shrink-0 mt-1">
                  <FileText className="h-5 w-5 text-cyan-400" />
                </div>
                <div>
                  <h4 className="font-medium text-black mb-1">Технические характеристики</h4>
                  <p className="text-gray-600 text-sm">Подробные спецификации всех типов дверей</p>
                </div>
              </div>
              
              <div className="flex items-start space-x-4">
                <div className="w-10 h-10 bg-cyan-50 rounded-lg flex items-center justify-center flex-shrink-0 mt-1">
                  <Download className="h-5 w-5 text-cyan-400" />
                </div>
                <div>
                  <h4 className="font-medium text-black mb-1">Сертификаты и документы</h4>
                  <p className="text-gray-600 text-sm">Все необходимые разрешительные документы</p>
                </div>
              </div>
              
              <div className="flex items-start space-x-4">
                <div className="w-10 h-10 bg-cyan-50 rounded-lg flex items-center justify-center flex-shrink-0 mt-1">
                  <BookOpen className="h-5 w-5 text-cyan-400" />
                </div>
                <div>
                  <h4 className="font-medium text-black mb-1">Примеры проектов</h4>
                  <p className="text-gray-600 text-sm">Реальные кейсы и фотографии установок</p>
                </div>
              </div>
            </div>
          </div>

          {/* Right Form */}
          <div>
            <Card className="shadow-xl border-0">
              <CardContent className="p-8">
                <h3 className="text-2xl font-medium text-black mb-2">
                  Получить каталог
                </h3>
                <p className="text-gray-600 mb-6">
                  Оставьте контакты и получите каталог на email
                </p>
                
                <form className="space-y-4" onSubmit={handleFormSubmit}>
                  <div>
                    <Label htmlFor="cat-name">Имя *</Label>
                    <Input 
                      id="cat-name" 
                      placeholder="Ваше имя"
                      className="bg-gray-50 border-gray-200"
                    />
                  </div>
                  
                  <div>
                    <Label htmlFor="cat-email">Email *</Label>
                    <Input 
                      id="cat-email" 
                      type="email"
                      placeholder="email@company.ru"
                      className="bg-gray-50 border-gray-200"
                    />
                  </div>
                  
                  <div>
                    <Label htmlFor="cat-company">Компания</Label>
                    <Input 
                      id="cat-company" 
                      placeholder="Название организации"
                      className="bg-gray-50 border-gray-200"
                    />
                  </div>
                  
                  <div>
                    <Label htmlFor="cat-position">Должность</Label>
                    <Select>
                      <SelectTrigger className="bg-gray-50 border-gray-200">
                        <SelectValue placeholder="Выберите должность" />
                      </SelectTrigger>
                      <SelectContent>
                        <SelectItem value="director">Главный врач / Директор</SelectItem>
                        <SelectItem value="engineer">Главный инженер</SelectItem>
                        <SelectItem value="procurement">Отдел закупок</SelectItem>
                        <SelectItem value="maintenance">Служба эксплуатации</SelectItem>
                        <SelectItem value="project">Проектировщик</SelectItem>
                        <SelectItem value="other">Другое</SelectItem>
                      </SelectContent>
                    </Select>
                  </div>
                  
                  <div>
                    <Label className="text-base font-medium mb-3 block">Интересующая продукция</Label>
                    <div className="grid grid-cols-2 gap-4">
                      <div className="flex items-center space-x-2">
                        <Checkbox id="cat-all" name="cat-interest" value="all" />
                        <Label htmlFor="cat-all" className="text-sm font-normal cursor-pointer">
                          Весь каталог
                        </Label>
                      </div>

                      <div className="flex items-center space-x-2">
                        <Checkbox id="cat-cabinet" name="cat-interest" value="cabinet" />
                        <Label htmlFor="cat-cabinet" className="text-sm font-normal cursor-pointer">
                          Двери для кабинетов
                        </Label>
                      </div>

                      <div className="flex items-center space-x-2">
                        <Checkbox id="cat-ward" name="cat-interest" value="ward" />
                        <Label htmlFor="cat-ward" className="text-sm font-normal cursor-pointer">
                          Двери для палат
                        </Label>
                      </div>

                      <div className="flex items-center space-x-2">
                        <Checkbox id="cat-xray" name="cat-interest" value="xray" />
                        <Label htmlFor="cat-xray" className="text-sm font-normal cursor-pointer">
                          Рентгенозащитные
                        </Label>
                      </div>

                      <div className="flex items-center space-x-2">
                        <Checkbox id="cat-fire" name="cat-interest" value="fire" />
                        <Label htmlFor="cat-fire" className="text-sm font-normal cursor-pointer">
                          Противопожарные
                        </Label>
                      </div>

                      <div className="flex items-center space-x-2">
                        <Checkbox id="cat-surgery" name="cat-interest" value="surgery" />
                        <Label htmlFor="cat-surgery" className="text-sm font-normal cursor-pointer">
                          Двери для операционных
                        </Label>
                      </div>
                    </div>
                  </div>
                  
                  <Button
                    type="submit"
                    disabled={isSubmitting}
                    className="w-full bg-cyan-400 hover:bg-cyan-500 text-white py-3 disabled:opacity-50"
                  >
                    {isSubmitting ? (
                      <>
                        <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                        Отправка...
                      </>
                    ) : (
                      'Скачать каталог'
                    )}
                  </Button>

                  {submitError && (
                    <p className="text-xs text-red-500 text-center mt-2">
                      {submitError}
                    </p>
                  )}

                  {submitSuccess && (
                    <p className="text-xs text-green-500 text-center mt-2">
                      ✅ Спасибо! Мы получили вашу заявку и отправим каталог на указанный email.
                    </p>
                  )}

                  <p className="text-xs text-gray-500 text-center">
                    Каталог будет отправлен на указанный email в течение 5 минут
                  </p>
                </form>
              </CardContent>
            </Card>
          </div>
        </div>
      </div>
    </section>
  );
}