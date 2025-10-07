import React, { useState } from "react";
import { Card, CardContent } from "./ui/card";
import { Button } from "./ui/button";
import { Input } from "./ui/input";
import { Label } from "./ui/label";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "./ui/select";
import { Textarea } from "./ui/textarea";
import { Checkbox } from "./ui/checkbox";
import { Calculator, Loader2 } from "lucide-react";
import TelegramService from "../services/telegramService";

export function CalculatorSection() {
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
    const doorTypes = formData.getAll('door-types') as string[];
    const data: { [key: string]: string } = {};

    // Копируем все данные формы
    for (let [key, value] of formData.entries()) {
      if (key !== 'door-types') {
        data[key] = value as string;
      }
    }

    // Обрабатываем чекбоксы типов дверей
    if (doorTypes.length > 0) {
      const doorLabels: { [key: string]: string } = {
        'cabinet': 'Двери для кабинетов',
        'ward': 'Двери для палат',
        'xray': 'Рентгенозащитные',
        'fire': 'Противопожарные',
        'surgery': 'Двери для операционных',
        'mixed': 'Другие типы'
      };

      const selectedDoors = doorTypes.map(type => doorLabels[type] || type);
      data['door-types'] = selectedDoors.join(', ');
    }

    try {
      const telegramService = TelegramService.getInstance();
      await telegramService.sendMessage(data, 'Форма калькулятора стоимости');

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
        <div className="max-w-4xl mx-auto">
          <div className="text-center mb-12">
            <div className="w-16 h-16 bg-cyan-50 rounded-full flex items-center justify-center mx-auto mb-6">
              <Calculator className="h-8 w-8 text-cyan-400" />
            </div>
            <h2 className="text-4xl font-light text-black mb-4">
              Рассчитайте стоимость проекта
            </h2>
            <p className="text-xl text-gray-600">
              Получите коммерческое предложение в течение 24 часов
            </p>
          </div>

          <Card className="shadow-xl border-0">
            <CardContent className="p-8">
              <form className="grid md:grid-cols-2 gap-6" onSubmit={handleFormSubmit}>
                <div>
                  <Label htmlFor="contact-name">Контактное лицо *</Label>
                  <Input 
                    id="contact-name" 
                    placeholder="ФИО ответственного"
                    className="bg-gray-50 border-gray-200"
                  />
                </div>
                
                <div>
                  <Label htmlFor="organization">Организация *</Label>
                  <Input 
                    id="organization" 
                    placeholder="Название медучреждения"
                    className="bg-gray-50 border-gray-200"
                  />
                </div>
                
                <div>
                  <Label htmlFor="calc-phone">Телефон *</Label>
                  <Input 
                    id="calc-phone" 
                    placeholder="+7 (___) ___-__-__"
                    className="bg-gray-50 border-gray-200"
                  />
                </div>
                
                <div>
                  <Label htmlFor="email">Email</Label>
                  <Input 
                    id="email" 
                    type="email"
                    placeholder="email@company.ru"
                    className="bg-gray-50 border-gray-200"
                  />
                </div>
                
                <div>
                  <Label htmlFor="facility-type">Тип учреждения *</Label>
                  <Select>
                    <SelectTrigger className="bg-gray-50 border-gray-200">
                      <SelectValue placeholder="Выберите тип" />
                    </SelectTrigger>
                    <SelectContent>
                      <SelectItem value="hospital">Больница</SelectItem>
                      <SelectItem value="clinic">Поликлиника</SelectItem>
                      <SelectItem value="medcenter">Медицинский центр</SelectItem>
                      <SelectItem value="laboratory">Лаборатория</SelectItem>
                      <SelectItem value="diagnostic">Диагностический центр</SelectItem>
                      <SelectItem value="other">Другое</SelectItem>
                    </SelectContent>
                  </Select>
                </div>
                
                <div>
                  <Label htmlFor="doors-count">Количество дверей</Label>
                  <Select>
                    <SelectTrigger className="bg-gray-50 border-gray-200">
                      <SelectValue placeholder="Выберите количество" />
                    </SelectTrigger>
                    <SelectContent>
                      <SelectItem value="1-10">1-10 дверей</SelectItem>
                      <SelectItem value="11-50">11-50 дверей</SelectItem>
                      <SelectItem value="51-100">51-100 дверей</SelectItem>
                      <SelectItem value="100+">Более 100 дверей</SelectItem>
                    </SelectContent>
                  </Select>
                </div>
                
                <div className="md:col-span-2">
                  <Label className="text-base font-medium mb-3 block">Типы дверей *</Label>
                  <div className="grid grid-cols-2 md:grid-cols-3 gap-4">
                    <div className="flex items-center space-x-2">
                      <Checkbox id="door-cabinet" name="door-types" value="cabinet" />
                      <Label htmlFor="door-cabinet" className="text-sm font-normal cursor-pointer">
                        Двери для кабинетов
                      </Label>
                    </div>

                    <div className="flex items-center space-x-2">
                      <Checkbox id="door-ward" name="door-types" value="ward" />
                      <Label htmlFor="door-ward" className="text-sm font-normal cursor-pointer">
                        Двери для палат
                      </Label>
                    </div>

                    <div className="flex items-center space-x-2">
                      <Checkbox id="door-xray" name="door-types" value="xray" />
                      <Label htmlFor="door-xray" className="text-sm font-normal cursor-pointer">
                        Рентгенозащитные
                      </Label>
                    </div>

                    <div className="flex items-center space-x-2">
                      <Checkbox id="door-fire" name="door-types" value="fire" />
                      <Label htmlFor="door-fire" className="text-sm font-normal cursor-pointer">
                        Противопожарные
                      </Label>
                    </div>

                    <div className="flex items-center space-x-2">
                      <Checkbox id="door-surgery" name="door-types" value="surgery" />
                      <Label htmlFor="door-surgery" className="text-sm font-normal cursor-pointer">
                        Двери для операционных
                      </Label>
                    </div>

                    <div className="flex items-center space-x-2">
                      <Checkbox id="door-mixed" name="door-types" value="mixed" />
                      <Label htmlFor="door-mixed" className="text-sm font-normal cursor-pointer">
                        Другие типы
                      </Label>
                    </div>
                  </div>
                </div>
                
                <div className="md:col-span-2">
                  <Label htmlFor="project-details">Описание проекта</Label>
                  <Textarea 
                    id="project-details" 
                    placeholder="Опишите особенности проекта, сроки, дополнительные требования..."
                    className="bg-gray-50 border-gray-200 min-h-[100px]"
                  />
                </div>
                
                <div className="md:col-span-2">
                  <Button
                    type="submit"
                    disabled={isSubmitting}
                    className="w-full bg-black hover:bg-gray-800 text-white py-4 disabled:opacity-50"
                  >
                    {isSubmitting ? (
                      <>
                        <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                        Отправка...
                      </>
                    ) : (
                      'Рассчитать стоимость проекта'
                    )}
                  </Button>

                  {submitError && (
                    <p className="text-xs text-red-500 text-center mt-2">
                      {submitError}
                    </p>
                  )}

                  {submitSuccess && (
                    <p className="text-xs text-green-500 text-center mt-2">
                      ✅ Спасибо! Мы получили вашу заявку и свяжемся с вами в ближайшее время.
                    </p>
                  )}

                  <p className="text-xs text-gray-500 text-center mt-3">
                    * Поля, обязательные для заполнения
                  </p>
                </div>
              </form>
            </CardContent>
          </Card>
          
          <div className="text-center mt-8">
            <p className="text-gray-600">
              Менеджер свяжется с вами в течение 30 минут для уточнения деталей
            </p>
          </div>
        </div>
      </div>
    </section>
  );
}