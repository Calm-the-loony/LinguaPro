import React from 'react';
import { MessageSquare, Globe, Book, Zap, Clock, CheckCircle, Star, Users } from 'lucide-react';
import './ServicesSection.css';

const ServicesSection = () => {
  const handleContact = () => {
    const contactSection = document.getElementById('contact');
    if (contactSection) {
      contactSection.scrollIntoView({ behavior: 'smooth' });
    }
  };

  return (
    <section id="services" className="ss-section">
      {/* Фоновые разводы */}
      <div className="ss-background">
        <div className="ss-gradient"></div>
        <div className="ss-blob ss-blob-1"></div>
        <div className="ss-blob ss-blob-2"></div>
        <div className="ss-blob ss-blob-3"></div>
      </div>

      <div className="ss-container">
        {/* Заголовок */}
        <div className="ss-header">
          <h2 className="ss-title">
            Услуги и <span className="ss-gradient-text">цены</span>
          </h2>
          <p className="ss-subtitle">
            Прозрачное ценообразование и гибкие условия обучения для достижения ваших целей
          </p>
        </div>

        {/* Первое занятие */}
        <div className="ss-consultation-card">
          <div className="ss-consultation-content">
            <div className="ss-consultation-icon-wrapper">
              <MessageSquare className="ss-consultation-icon" />
            </div>
            <div className="ss-consultation-text">
              <h3>Первое занятие</h3>
              <p>Определим ваш уровень, цели и составим индивидуальный план обучения</p>
              <div className="ss-consultation-details">
                <div className="ss-detail-item">
                  <CheckCircle className="ss-detail-icon" />
                  <span>Тестирование уровня</span>
                </div>
                <div className="ss-detail-item">
                  <CheckCircle className="ss-detail-icon" />
                  <span>Постановка целей</span>
                </div>
                <div className="ss-detail-item">
                  <CheckCircle className="ss-detail-icon" />
                  <span>План обучения</span>
                </div>
              </div>
            </div>
            <div className="ss-consultation-action">
              <button className="ss-consultation-btn" onClick={handleContact}>
                Записаться
              </button>
            </div>
          </div>
        </div>

        <div className="ss-languages-grid">
          <div className="ss-language-card">
            <div className="ss-card-header">
              <div className="ss-language-icon-wrapper">
                <Globe className="ss-language-icon" />
              </div>
              <div className="ss-language-title">
                <h3>Испанский язык</h3>
                <p>Индивидуальные занятия онлайн</p>
              </div>
              <div className="ss-popular-badge">Популярно</div>
            </div>

            <div className="ss-pricing-table">
              <div className="ss-price-row">
                <div className="ss-price-info">
                  <span className="ss-price-name">Разовое занятие</span>
                  <span className="ss-price-desc">Продолжительность 60 минут</span>
                </div>
                <div className="ss-price-value">2 000 ₽</div>
              </div>
              <div className="ss-price-row">
                <div className="ss-price-info">
                  <span className="ss-price-name">Занятие 90 минут</span>
                  <span className="ss-price-desc">Более интенсивно</span>
                </div>
                <div className="ss-price-value">2 800 ₽</div>
              </div>
              <div className="ss-price-row ss-featured">
                <div className="ss-price-info">
                  <span className="ss-price-name">Абонемент на месяц</span>
                  <span className="ss-price-desc">4 занятия • Лучшее предложение</span>
                </div>
                <div className="ss-price-value">7 600 ₽</div>
              </div>
            </div>

            <div className="ss-card-features">
              <div className="ss-feature">
                <Users className="ss-feature-icon" />
                <span>Индивидуальный подход</span>
              </div>
              <div className="ss-feature">
                <Clock className="ss-feature-icon" />
                <span>Гибкий график</span>
              </div>
            </div>

            <button className="ss-language-btn" onClick={handleContact}>
              Выбрать испанский
            </button>
          </div>

          {/* Английский */}
          <div className="ss-language-card">
            <div className="ss-card-header">
              <div className="ss-language-icon-wrapper">
                <Book className="ss-language-icon" />
              </div>
              <div className="ss-language-title">
                <h3>Английский язык</h3>
                <p>Индивидуальные занятия онлайн</p>
              </div>
            </div>

            <div className="ss-pricing-table">
              <div className="ss-price-row">
                <div className="ss-price-info">
                  <span className="ss-price-name">Разовое занятие</span>
                  <span className="ss-price-desc">Продолжительность 60 минут</span>
                </div>
                <div className="ss-price-value">1 800 ₽</div>
              </div>
              <div className="ss-price-row">
                <div className="ss-price-info">
                  <span className="ss-price-name">Занятие 90 минут</span>
                  <span className="ss-price-desc">Более интенсивно</span>
                </div>
                <div className="ss-price-value">2 500 ₽</div>
              </div>
              <div className="ss-price-row ss-featured">
                <div className="ss-price-info">
                  <span className="ss-price-name">Абонемент на месяц</span>
                  <span className="ss-price-desc">4 занятия • Лучшее предложение</span>
                </div>
                <div className="ss-price-value">6 800 ₽</div>
              </div>
            </div>

            <div className="ss-card-features">
              <div className="ss-feature">
                <Star className="ss-feature-icon" />
                <span>Английский для путешествий</span>
              </div>
              <div className="ss-feature">
                <MessageSquare className="ss-feature-icon" />
                <span>Разговорная практика</span>
              </div>
            </div>

            <button className="ss-language-btn" onClick={handleContact}>
              Выбрать английский
            </button>
          </div>
        </div>

        {/* Специальное предложение - изменено */}
        <div className="ss-special-offer">
          <div className="ss-offer-content">
            <div className="ss-offer-icon-wrapper">
              <Zap className="ss-offer-icon" />
            </div>
            <div className="ss-offer-text">
              <div className="ss-offer-badge">Специальное предложение</div>
              <h3>Скидка на первое занятие</h3>
              <div className="ss-offer-price">
                <span className="ss-old-price">1 800 ₽</span>
                <span className="ss-new-price">1 200 ₽</span>
                <span className="ss-discount">-33%</span>
              </div>
            </div>
            <button className="ss-offer-btn" onClick={handleContact}>
              Получить скидку
            </button>
          </div>
        </div>

        {/* Информационный блок */}
        <div className="ss-info-section">
          <div className="ss-info-card">
            <Clock className="ss-info-icon" />
            <div className="ss-info-content">
              <h4>Гибкий график занятий</h4>
              <p>Подбираем удобное время для занятий онлайн. Учитесь из любого места в удобное для вас время</p>
            </div>
          </div>
          <div className="ss-info-card">
            <Star className="ss-info-icon" />
            <div className="ss-info-content">
              <h4>Индивидуальная программа</h4>
              <p>Каждому ученику составляется персональный план обучения с учетом целей и интересов</p>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
};

export default ServicesSection;