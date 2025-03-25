/*
* Данная бд отображает приблизительную бд одного из форумов, https://www.harrypotter.com.ua. Форум достаточно большой и активный, создан по миру Гарри Поттера. Здесь я преимущественно отобразила 
* одну из важнейших структур форума - школу Хогвартс (директором которой я работаю на протяжении последних 1,5 лет). С её преподавателями, предметами и лекциями. Так же вкользь отображены 
* модераторы и прочие должности. И, конечно же, есть маг.информация юзеров, заклинания и их применения друг на друга. 
*/


DROP DATABASE IF EXISTS magic_forum;

CREATE DATABASE IF NOT EXISTS magic_forum;

USE magic_forum;

CREATE TABLE `users` (
    `id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY, 
    `first_name` VARCHAR(150), 
    `last_name` VARCHAR(150),
    `nick` VARCHAR(150) NOT NULL,
    `email` VARCHAR(150) NOT NULL UNIQUE, 
    `passworod_hash` CHAR(65) DEFAULT NULL,  
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP, 
    `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX(email)
);


CREATE TABLE `profiles` (
    `user_id` BIGINT UNSIGNED NOT NULL PRIMARY KEY, 
    `gender` ENUM('f', 'm', 'x') NOT NULL, 
    `birthday` DATE,
    `city` VARCHAR(150),
    `country` VARCHAR(150),
    FOREIGN KEY(`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE ON UPDATE CASCADE 
);


CREATE TABLE `messages` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `from_user_id` BIGINT UNSIGNED NOT NULL,
  `to_user_id` BIGINT UNSIGNED NOT NULL,
  `txt` TEXT NOT NULL,
  `is_delivered` TINYINT(1) DEFAULT '0',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  FOREIGN KEY (`from_user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (`to_user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE 
);


-- табличка должностей на форуме
CREATE TABLE `position` (
	`id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY, 
	`name` VARCHAR(45) NOT NULL,
	`salary` DECIMAL(11,2) NOT NULL,
 	 UNIQUE KEY `name` (`name`)
 );

 
  -- табличка предметов для преподавателей, инспекторов и корректоров + подфорумов для модераторов и СМ
CREATE TABLE `item` (
	`id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY, 
	`name` VARCHAR(45) NOT NULL UNIQUE,
    `id_position` BIGINT UNSIGNED, -- указание на тип должности из таблички position
	FOREIGN KEY (`id`) REFERENCES `position`(`id`) ON DELETE CASCADE ON UPDATE CASCADE 
 );


 -- табличка взаимосвязи юзеров и их должностей на форуме
CREATE TABLE `position_users` (
    `position_id` BIGINT UNSIGNED NOT NULL, -- id должностей из таблички position
    `item_id` BIGINT UNSIGNED NOT NULL, -- id предмета/подфорума
    `user_id` BIGINT UNSIGNED NOT NULL,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `update_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`position_id`, `user_id`, `item_id`),
    FOREIGN KEY (`position_id`) REFERENCES `position`(`id`) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (`item_id`) REFERENCES `item`(`id`) ON DELETE CASCADE ON UPDATE CASCADE 
);
 
 
-- табличка лекций в предметах/тем в подфорумах
CREATE TABLE `lectures` (
    `id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `item_id` BIGINT UNSIGNED NOT NULL, -- id предмета/подфорума
    `name` VARCHAR(45) NOT NULL,
    `txt` TEXT NOT NULL,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `update_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (`item_id`) REFERENCES `item`(`id`) ON DELETE CASCADE ON UPDATE CASCADE 
);

 
-- табличка сданных заданий по лекциям
CREATE TABLE `lectures_users` (
    `lectures_id` BIGINT UNSIGNED NOT NULL, -- id лекций из таблички lectures
    `item_id` BIGINT UNSIGNED NOT NULL, -- id предмета/подфорума
    `user_id` BIGINT UNSIGNED NOT NULL, -- кто сдал задания по лекции
    `grade` DECIMAL(11,2), -- оценка за задание
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `update_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`lectures_id`, `user_id`, `item_id`),
    FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (`item_id`) REFERENCES `item`(`id`) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (`lectures_id`) REFERENCES `lectures`(`id`) ON DELETE CASCADE ON UPDATE CASCADE 
);
 

-- табличка книги заклинаний
CREATE TABLE `spells` (
	`id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY, 
	`name` VARCHAR(45) NOT NULL UNIQUE,
    `description` TEXT NOT NULL -- описание заклинания
);
 

-- табличка заюза заклинаний
CREATE TABLE `spells_users` (
    `spells_id` BIGINT UNSIGNED NOT NULL, -- id заклинания из таблички spells
    `from_user_id` BIGINT UNSIGNED NOT NULL, -- кто наложил заклинание
    `to_user_id` BIGINT UNSIGNED NOT NULL, -- на кого наложили заклинание
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`spells_id`, `to_user_id`, `from_user_id`),
    FOREIGN KEY (`spells_id`) REFERENCES `spells`(`id`) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (`from_user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (`to_user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
);
 

-- табличка уровней волшебника
CREATE TABLE `magic_lvl` (
	`id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY, 
	`name` VARCHAR(45) NOT NULL
);

 
-- волшебный профиль 
CREATE TABLE `magic_users` (
    `user_id` BIGINT UNSIGNED NOT NULL, 
    `magic_lvl_id` BIGINT UNSIGNED, -- уровень прокачки волшебника из таблички magic_lvl
    `stability` BIGINT NOT NULL, -- показатель устойчивости
    `concentration` BIGINT NOT NULL, -- показатель концентрации
    `mana_replenishment` BIGINT NOT NULL, -- показатель восполнения маны
    FOREIGN KEY (`magic_lvl_id`) REFERENCES `magic_lvl`(`id`) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
);
 
 
-- Cкрипты наполнения БД данными
INSERT INTO `users` VALUES (DEFAULT,'Элиза','Суморокова','Volshebnitsa','eliza.t-a@ya.ru','123456', DEFAULT, DEFAULT)
(DEFAULT,'Лаура','Гондарева','Volshebtvo','layrinna@mail.ru','123456', DEFAULT, DEFAULT),
(DEFAULT,'Иван','Иванов','Magic_people','1111@ya.ru','123456', DEFAULT, DEFAULT),
(DEFAULT,'Петр','Петров','Xerox','2222@ya.ru','123456', DEFAULT, DEFAULT),
(DEFAULT,'Анна','Васильева','Boginya','333@ya.ru','123456', DEFAULT, DEFAULT),
(DEFAULT,'Евгений','Новиков','Cevas','4444@ya.ru','123456', DEFAULT, DEFAULT),
(DEFAULT,'Елена','Трубач','Mella','5555@ya.ru','123456', DEFAULT, DEFAULT),
(DEFAULT,'Ольга','Белова','Juk_olya','66666@ya.ru','123456', DEFAULT, DEFAULT),
(DEFAULT,'Александр','Краков','Kraken','7777@ya.ru','123456', DEFAULT, DEFAULT),
(DEFAULT,'Сергей','Равич','Icy Archimage','8888@ya.ru','123456', DEFAULT, DEFAULT);
 
 
INSERT INTO `profiles` VALUES (1,'f','1993-09-08','Москва','Россия'),
(2,'f','1988-07-16','Кропоткин','Россия'),
(3,'m','1989-05-15','Харьков','Украина'),
(4,'m','1986-03-07','Ставрополь','Россия'),
(5,'f','1992-03-07','Краснодар','Россия'),
(6,'m','1991-02-11','Москва','Россия'),
(7,'f','1985-01-30','Киев','Украина'),
(8,'f','1990-10-28','Саратов','Россия'),
(9,'m','1995-04-02','Одесса','Украина'),
(10,'m','1987-06-03','Кривой Рог','Украина');

 
INSERT INTO `messages` VALUES (DEFAULT, 1, 2, 'Ты когда в Москву?', DEFAULT, DEFAULT, DEFAULT),
(DEFAULT, 2, 1, 'Как обычно, в начале лета', DEFAULT, DEFAULT, DEFAULT),
(DEFAULT, 1, 2, 'Долго ждать(((', DEFAULT, DEFAULT, DEFAULT),
(DEFAULT, 3, 4, 'Привет, ты какие предметы будешь сдавать в этом году?', DEFAULT, DEFAULT, DEFAULT),
(DEFAULT, 4, 3, 'Думаю, толкование снов и магию камней. А ты?', DEFAULT, DEFAULT, DEFAULT),
(DEFAULT, 3, 4, 'И я думаю их сдать', DEFAULT, DEFAULT, DEFAULT),
(DEFAULT, 5, 6, 'Спасибо за обкаст!', DEFAULT, DEFAULT, DEFAULT),
(DEFAULT, 7, 8, 'Ты остаёшься модератором на следующий год?', DEFAULT, DEFAULT, DEFAULT),
(DEFAULT, 8, 7, 'Да, думаю, еще годик поработаю', DEFAULT, DEFAULT, DEFAULT),
(DEFAULT, 9, 10, 'Напиши, когда будешь в сети, я на тебя классный баф кастану', DEFAULT, DEFAULT, DEFAULT);
 

INSERT INTO `position` VALUES (DEFAULT, 'Старший Администратор', 6000),
(DEFAULT, 'Администратор', 6000),
(DEFAULT, 'Супермодератор', 4000),
(DEFAULT, 'Модератор', 2000),
(DEFAULT, 'Преподаватель', 4500),
(DEFAULT, 'Помощник преподавателя', 2500),
(DEFAULT, 'Инспектор', 2000),
(DEFAULT, 'Корректор', 2000),
(DEFAULT, 'Cекундант Дуэльного Клуба', 2700),
(DEFAULT, 'Анкетолог', 2000);


INSERT INTO `item` VALUES (DEFAULT, 'Магия камней', 5),
(DEFAULT, 'Толкование сновидений', 5),
(DEFAULT, 'Магический спорт', 5),
(DEFAULT, 'Алхимия', 5),
(DEFAULT, 'Анкеты Хогвартса', 10),
(DEFAULT, 'Литературный клуб', 4),
(DEFAULT, 'Музыка', 4),
(DEFAULT, 'Спорт', 4),
(DEFAULT, 'Дуэльный клуб Выручай-комната', 9),
(DEFAULT, 'Дуэльный клуб волшебной вселенной', 9);


INSERT INTO `position_users` VALUES (5, 1, 1, DEFAULT, DEFAULT),
(5, 2, 2, DEFAULT, DEFAULT),
(5, 3, 3, DEFAULT, DEFAULT),
(4, 6, 4, DEFAULT, DEFAULT),
(4, 7, 5, DEFAULT, DEFAULT),
(4, 8, 6, DEFAULT, DEFAULT),
(9, 9, 7, DEFAULT, DEFAULT),
(9, 10, 8, DEFAULT, DEFAULT),
(10, 5, 9, DEFAULT, DEFAULT),
(7, 4, 10, DEFAULT, DEFAULT);


INSERT INTO `lectures` VALUES (DEFAULT, 1, 'Оливин', 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua', DEFAULT, DEFAULT),
(DEFAULT, 2, 'Сны о море', 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua', DEFAULT, DEFAULT),
(DEFAULT, 3, 'Появление золотого снитча', 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua', DEFAULT, DEFAULT),
(DEFAULT, 4, 'Великие алхимики', 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua', DEFAULT, DEFAULT),
(DEFAULT, 6, 'Напиши стихотворение на заданную тему', 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua', DEFAULT, DEFAULT),
(DEFAULT, 7, 'Любимые песни', 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua', DEFAULT, DEFAULT),
(DEFAULT, 8, 'За кого болеешь в ЧМ 2021?', 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua', DEFAULT, DEFAULT),
(DEFAULT, 1, 'Гранат', 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua', DEFAULT, DEFAULT),
(DEFAULT, 2, 'Сны о Хеллоуине', 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua', DEFAULT, DEFAULT),
(DEFAULT, 3, 'Знаменитые игроки в квиддич', 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua', DEFAULT, DEFAULT);


INSERT INTO `lectures_users` VALUES (1, 1, 2, 5, DEFAULT, DEFAULT),
(2, 2, 1, 5, DEFAULT, DEFAULT),
(3, 2, 3, 5, DEFAULT, DEFAULT),
(4, 4, 5, 5, DEFAULT, DEFAULT),
(8, 1, 7, 5, DEFAULT, DEFAULT),
(9, 2, 8, 5, DEFAULT, DEFAULT),
(10, 3, 10, 4, DEFAULT, DEFAULT),
(1, 1, 6, 3, DEFAULT, DEFAULT),
(2, 2, 4, 5, DEFAULT, DEFAULT),
(3, 3, 9, 5, DEFAULT, DEFAULT);


INSERT INTO `spells` VALUES (DEFAULT, 'Inspiratio', 'Волшебник получает дополнительные бонусы +30% эффективности всех заклинаний, +30 концентрации, +15 устойчивости к магии'),
(DEFAULT, 'Animagus Miniature Fuzzy', 'Изменение облика. +3 концентрации, +3% эффективности всех заклинаний'),
(DEFAULT, 'Expelliarmus', 'Делает палочку недоступной'),
(DEFAULT, 'Finite Incantatem', 'Отменяет активное заклинание'),
(DEFAULT, 'Protego', 'Создает магический щит. Препятствует использованию на пользвателя различных заклинаний.'),
(DEFAULT, 'Impedimenta', 'Атакующее заклинание "ватных ног" -10 концентрации, -5 устойчивости к магии'),
(DEFAULT, 'Supervision', 'Позволяет видеть сквозь мантию-невидимку'),
(DEFAULT, 'Animagus Thunderbird', 'Изменение облика. +42 концентрации, +42% эффективности всех заклинаний, +42 устойчивости к магии, Поглощение мощности заклинаний +20%, +5% к опыту'),
(DEFAULT, 'Latens Amplificatory', 'Усиливает невидимость. Оказывает эффект только когда надета мантия-невидимка'),
(DEFAULT, 'Benedictus Ex', 'Улучшенное благословение +40% эффективности всех заклинаний, +5 концентрации, Поглощение мощности заклинаний -5%');
 

INSERT INTO `spells_users` VALUES (5, 6, 5, DEFAULT),
(7, 6, 5, DEFAULT),
(8, 6, 5, DEFAULT),
(10, 1, 2, DEFAULT),
(8, 2, 1, DEFAULT),
(4, 9, 4, DEFAULT),
(2, 10, 3, DEFAULT),
(6, 3, 7, DEFAULT),
(1, 8, 6, DEFAULT),
(2, 7, 8, DEFAULT);


INSERT INTO `magic_lvl` VALUES (DEFAULT, 'Начинающий волебник'),
(DEFAULT, 'Волшебник'),
(DEFAULT, 'Колдун'),
(DEFAULT, 'Заклинатель'),
(DEFAULT, 'Метаморфомаг'),
(DEFAULT, 'Магистр'),
(DEFAULT, 'Великий волшебник'),
(DEFAULT, 'Верховный чародeй'),
(DEFAULT, 'Архимагистр'),
(DEFAULT, 'Эпический волшебник');


INSERT INTO `magic_users` VALUES (1, 10, 700, 700, 700),
(2, 9, 650, 650, 650),
(3, 8, 600, 600, 600),
(4, 7, 550, 550, 550),
(5, 6, 500, 500, 500),
(6, 5, 450, 450, 450),
(7, 4, 400, 400, 400),
(8, 3, 300, 300, 300),
(9, 2, 200, 200, 200),
(10, 1, 100, 100, 100);
