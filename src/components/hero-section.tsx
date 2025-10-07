import React, { useState } from "react";
import { Button } from "./ui/button";
import { Input } from "./ui/input";
import { Label } from "./ui/label";
import { Card, CardContent } from "./ui/card";
import { Shield, Award, Truck, Loader2 } from "lucide-react";
import TelegramService from "../services/telegramService";

export function HeroSection() {
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [submitError, setSubmitError] = useState<string | null>(null);
  const [submitSuccess, setSubmitSuccess] = useState(false);

  const handleConsultationClick = () => {
    // Scroll to form or show modal - for now just scroll to form
    const form = document.querySelector('#consultation-form');
    if (form) {
      form.scrollIntoView({ behavior: 'smooth' });
    }
  };

  const handleFormSubmit = async (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    console.log('🚀 Форма отправляется...');

    setIsSubmitting(true);
    setSubmitError(null);
    setSubmitSuccess(false);

    const formData = new FormData(e.currentTarget);
    const data = Object.fromEntries(formData.entries()) as { [key: string]: string };
    console.log('📝 Данные формы:', data);

    try {
      console.log('📤 Отправка в Telegram...');
      const telegramService = TelegramService.getInstance();
      const result = await telegramService.sendMessage(data, 'Форма консультации (Hero Section)');
      console.log('📨 Результат отправки:', result);

      console.log('✅ Устанавливаем успех');
      setSubmitSuccess(true);
      e.currentTarget?.reset();

      // Скрываем сообщение об успехе через 5 секунд
      setTimeout(() => {
        setSubmitSuccess(false);
      }, 5000);

    } catch (error) {
      console.error('❌ Ошибка отправки формы:', error);
      setSubmitError('Произошла ошибка при отправке формы. Пожалуйста, попробуйте еще раз.');
    } finally {
      setIsSubmitting(false);
    }
  };

  return (
    <section 
      className="relative py-20 bg-cover bg-center bg-no-repeat"
      style={{
        backgroundImage: `linear-gradient(rgba(0, 0, 0, 0.4), rgba(0, 0, 0, 0.4)), url('https://avatars.mds.yandex.net/get-altay/14090612/2a000001941c9f2b86ab121958e3e7a155b7/XXL_height')`
      }}
    >
      <div className="container mx-auto px-4">
        <div className="grid lg:grid-cols-2 gap-12 items-center">
          {/* Left Content */}
          <div>
            <h1 className="text-5xl font-light text-white mb-6 leading-tight">
              Медицинские двери<br />
              <span className="text-cyan-400">под ключ</span>
            </h1>
            <p className="text-xl text-gray-200 mb-8 leading-relaxed">
              Производство и установка всех видов дверей для медицинских учреждений. 
              Рентгенозащитные, противопожарные, двери для палат и кабинетов.
            </p>
            
            {/* Features */}
            <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-10">
              <div className="flex items-center space-x-3">
                <div className="w-12 h-12 bg-cyan-50 rounded-lg flex items-center justify-center">
                  <Shield className="h-6 w-6 text-cyan-400" />
                </div>
                <div>
                  <div className="font-medium text-white">Сертификация</div>
                  <div className="text-sm text-gray-300">Все нормы и ГОСТы</div>
                </div>
              </div>
              
              <div className="flex items-center space-x-3">
                <div className="w-12 h-12 bg-cyan-50 rounded-lg flex items-center justify-center">
                  <Award className="h-6 w-6 text-cyan-400" />
                </div>
                <div>
                  <div className="font-medium text-white">25 лет опыта</div>
                  <div className="text-sm text-gray-300">1500+ проектов</div>
                </div>
              </div>
              
              <div className="flex items-center space-x-3">
                <div className="w-12 h-12 bg-cyan-50 rounded-lg flex items-center justify-center">
                  <Truck className="h-6 w-6 text-cyan-400" />
                </div>
                <div>
                  <div className="font-medium text-white">Установка</div>
                  <div className="text-sm text-gray-300">По всей России</div>
                </div>
              </div>
            </div>
          </div>

          {/* Right Form */}
          <div>
            <Card className="shadow-xl border-0">
              <CardContent className="p-8">
                <h3 className="text-2xl font-medium text-black mb-2">
                  Получите консультацию специалиста
                </h3>
                <p className="text-gray-600 mb-6">
                  Поможем подобрать решение под ваш проект
                </p>
                
                <form id="consultation-form" className="space-y-4" onSubmit={handleFormSubmit}>
                  <div>
                    <Label htmlFor="name">Ваше имя</Label>
                    <Input 
                      id="name" 
                      name="name"
                      placeholder="Введите имя"
                      className="bg-gray-50 border-gray-200"
                      required
                    />
                  </div>
                  
                  <div>
                    <Label htmlFor="company">Компания</Label>
                    <Input 
                      id="company" 
                      name="company"
                      placeholder="Название организации"
                      className="bg-gray-50 border-gray-200"
                      required
                    />
                  </div>
                  
                  <div>
                    <Label htmlFor="phone">Телефон</Label>
                    <Input 
                      id="phone" 
                      name="phone"
                      placeholder="+7 (___) ___-__-__"
                      className="bg-gray-50 border-gray-200"
                      type="tel"
                      required
                    />
                  </div>
                  
                  <div>
                    <Label htmlFor="project">Тип проекта</Label>
                    <Input 
                      id="project" 
                      name="project"
                      placeholder="Больница, клиника, медцентр..."
                      className="bg-gray-50 border-gray-200"
                    />
                  </div>
                  
                  <Button
                    type="submit"
                    disabled={isSubmitting}
                    className="w-full bg-black hover:bg-gray-800 text-white py-3 disabled:opacity-50"
                  >
                    {isSubmitting ? (
                      <>
                        <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                        Отправка...
                      </>
                    ) : (
                      'Получить консультацию'
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

                  <p className="text-xs text-gray-500 text-center">
                    Нажимая кнопку, вы соглашаетесь с политикой конфиденциальности
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