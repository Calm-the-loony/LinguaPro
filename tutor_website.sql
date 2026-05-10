-- phpMyAdmin SQL Dump
-- version 5.2.0
-- https://www.phpmyadmin.net/
--
-- Хост: 127.0.0.1:3307
-- Время создания: Май 10 2026 г., 21:55
-- Версия сервера: 5.7.39
-- Версия PHP: 7.2.34

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- База данных: `tutor_website`
--

-- --------------------------------------------------------

--
-- Структура таблицы `bookings`
--

CREATE TABLE `bookings` (
  `id` int(11) NOT NULL,
  `name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `phone` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `service` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `level` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `age_group` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `frequency` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `message` text COLLATE utf8mb4_unicode_ci,
  `status` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT 'new',
  `agree_terms` tinyint(1) DEFAULT '0',
  `agree_newsletter` tinyint(1) DEFAULT '0',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Дамп данных таблицы `bookings`
--

INSERT INTO `bookings` (`id`, `name`, `email`, `phone`, `service`, `level`, `age_group`, `frequency`, `message`, `status`, `agree_terms`, `agree_newsletter`, `created_at`, `updated_at`) VALUES
(1, 'Анна Иванова', 'anna@example.com', '+7 (999) 123-45-67', 'ielts', 'intermediate', '26-40', NULL, 'Нужна подготовка к IELTS на 7.5', 'cancelled', 1, 0, '2026-01-22 07:31:26', '2026-02-01 18:55:20'),
(2, 'Максим Петров', 'max@example.com', '+7 (999) 987-65-43', 'business', 'upper-intermediate', '26-40', NULL, 'Бизнес-английский для переговоров', 'cancelled', 1, 0, '2026-01-22 07:31:26', '2026-01-25 19:43:01'),
(3, 'София Сидорова', 'sofia@example.com', '+7 (999) 555-55-55', 'children', 'beginner', '7-12', NULL, 'Английский для ребенка 10 лет', 'new', 1, 0, '2026-01-22 07:31:26', '2026-01-22 07:31:26'),
(4, 'fbdfb', 'riya.p0@mail.ru', '89655254511', 'english-travel', 'beginner', '13-17', '2', 'fdghjkl', 'new', 1, 1, '2026-05-09 09:35:55', '2026-05-09 09:35:55');

-- --------------------------------------------------------

--
-- Структура таблицы `booking_notes`
--

CREATE TABLE `booking_notes` (
  `id` int(11) NOT NULL,
  `booking_id` int(11) NOT NULL,
  `notes` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Структура таблицы `reviews`
--

CREATE TABLE `reviews` (
  `id` int(11) NOT NULL,
  `name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `position` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `text` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `rating` int(11) DEFAULT NULL,
  `status` enum('pending','approved','rejected') COLLATE utf8mb4_unicode_ci DEFAULT 'pending',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Дамп данных таблицы `reviews`
--

INSERT INTO `reviews` (`id`, `name`, `position`, `text`, `rating`, `status`, `created_at`, `updated_at`) VALUES
(1, 'Алексей', 'Ученик', 'Могу сказать что, заниматся с вами одно удовольствие, хорошая подача и объяснение материала, присутсвует разнообразие в занятиях что добавляет интереса, даёте мотивацию, лучший учитель для английского языка', 5, 'approved', '2026-04-07 09:32:34', '2026-04-07 09:32:34'),
(2, 'Татьяна', 'Ученица', 'Мне очень нравится. Раньше я занималась с репетитором и всё было как-то однообразно. А ты мне и видео разные даёшь, и сериалы рекомендуешь, и более углублённо обучение проходит', 5, 'approved', '2026-04-07 09:32:34', '2026-04-07 09:32:34'),
(3, 'Лариса', 'Родитель', 'Насте очень понравилось с вами, это первый раз такая реакция от английского. Вы её возьмёте на обучение?', 5, 'approved', '2026-04-07 09:32:34', '2026-04-07 09:32:34'),
(4, 'Яна', 'Ученица', 'Даша, спасибо Вам за понимание и что Вы у нас есть, это дорого стоит, ценю Ваш труд', 5, 'approved', '2026-04-07 09:32:34', '2026-04-07 09:32:34'),
(5, 'Алена', 'Родитель', 'У нас в четверти 5 по английскому языку', 5, 'approved', '2026-04-07 09:32:34', '2026-04-07 09:32:34'),
(6, 'Татьяна', 'Родитель', 'Даша! Я Вам очень благодарна за проделанную работу с Кириллом! Ему очень нравится с Вами работать! Мы и дальше остаемся с Вами! Наше место держите', 5, 'approved', '2026-04-07 09:32:34', '2026-04-07 09:32:34'),
(7, 'Вера', 'Ученица', 'Дарья добрый вечер, я хотела сказать спасибо большое вам что научили меня всему, я хоть и халтурила и плохо себя вела, но я полюбила вас как учителя, спасибо за знания', 5, 'approved', '2026-04-07 09:32:34', '2026-04-07 09:32:34'),
(8, 'Катя', 'Ученица', 'Я занимаюсь с Дашей всего месяц, и уже хотела бы оставить свой маленький отзыв. Наши уроки проходят в спокойной и комфортной атмосфере. Мне очень нравится способ преподнесения нового материала. И что для меня важно, Даша никогда не ругается, если что то не получается, а, наоборот, всегда поддерживает, из-за чего занятия проходят легко и с удовольствием!', 5, 'approved', '2026-04-07 09:32:34', '2026-04-07 09:32:34'),
(9, 'Диана', 'вма', 'ампрываип', 5, 'pending', '2026-05-05 15:56:51', '2026-05-05 15:56:51'),
(10, 'fbdfb', 'Студент', 'cvhgbjnkmfghj', 4, 'pending', '2026-05-09 09:35:21', '2026-05-09 09:35:21');

-- --------------------------------------------------------

--
-- Структура таблицы `users`
--

CREATE TABLE `users` (
  `id` int(11) NOT NULL,
  `username` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `password` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `role` enum('admin','tutor') COLLATE utf8mb4_unicode_ci DEFAULT 'tutor',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Дамп данных таблицы `users`
--

INSERT INTO `users` (`id`, `username`, `email`, `password`, `role`, `created_at`, `updated_at`) VALUES
(2, 'daria', 'daria.gritsaenko2000@gmail.com', '$2b$10$N9qo8uLOickgx2ZMRZoMy.Mrq7gq6J3q9Q7Z2Mq5Q8L...', 'admin', '2026-01-28 20:40:43', '2026-01-28 20:40:43');

--
-- Индексы сохранённых таблиц
--

--
-- Индексы таблицы `bookings`
--
ALTER TABLE `bookings`
  ADD PRIMARY KEY (`id`);

--
-- Индексы таблицы `booking_notes`
--
ALTER TABLE `booking_notes`
  ADD PRIMARY KEY (`id`),
  ADD KEY `booking_id` (`booking_id`);

--
-- Индексы таблицы `reviews`
--
ALTER TABLE `reviews`
  ADD PRIMARY KEY (`id`);

--
-- Индексы таблицы `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `username` (`username`),
  ADD UNIQUE KEY `email` (`email`);

--
-- AUTO_INCREMENT для сохранённых таблиц
--

--
-- AUTO_INCREMENT для таблицы `bookings`
--
ALTER TABLE `bookings`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT для таблицы `booking_notes`
--
ALTER TABLE `booking_notes`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT для таблицы `reviews`
--
ALTER TABLE `reviews`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT для таблицы `users`
--
ALTER TABLE `users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- Ограничения внешнего ключа сохраненных таблиц
--

--
-- Ограничения внешнего ключа таблицы `booking_notes`
--
ALTER TABLE `booking_notes`
  ADD CONSTRAINT `booking_notes_ibfk_1` FOREIGN KEY (`booking_id`) REFERENCES `bookings` (`id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
