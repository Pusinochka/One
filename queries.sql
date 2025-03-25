USE magic_forum;

/*
 * скрипты характерных выборок (включающие группировки, JOIN'ы, вложенные таблицы)
 */

-- выведем имя и фамилию юзера, который написал больше всех сообщений юзеру с id = 2
SELECT CONCAT(u.first_name, ' ', u.last_name) AS spamer, COUNT(*) AS count_messages
	FROM messages m 
	JOIN users u ON m.from_user_id = u.id
	WHERE to_user_id = 2;


-- выведем ники пользователей, название предметов и лекций, по которым они сдали работы. А так же оценку, которую получили
SELECT u.nick AS 'Ник', i.name AS 'Предмет', l.name AS 'Лекция', lu2.grade AS 'Оценка'
	FROM lectures_users lu 
	JOIN users u ON lu.user_id = u.id
    JOIN item i ON lu.item_id = i.id 
    JOIN lectures l ON l.id = lu.lectures_id
    JOIN lectures_users lu2 ON lu.user_id = lu2.user_id
    ORDER BY i.name;

   
-- выведем по какому предмету сколько работ сдали 
SELECT l.name, COUNT(*) AS 'Сдано работ'
	FROM lectures_users lu
	JOIN lectures l ON lu.lectures_id = l.id 
	GROUP BY lu.lectures_id;
   
   
-- выведем ник и маг.уровень пользователя
SELECT u.nick AS 'Ник', mag.name AS 'Маг.уровень', 
FROM magic_users mu 
    JOIN users u ON mu.user_id = u.id
	JOIN magic_lvl mag ON mu.magic_lvl_id = mag.id; 



/*
 * Представления (минимум 2)
 */

-- представление для вывода всех кастов пользователя
CREATE or REPLACE VIEW cast_users
AS
SELECT u.nick AS 'Ник', s.name 'Заклинание', u2.nick AS 'На кого кастовал'
FROM spells_users sp
	JOIN users u ON u.id = sp.from_user_id 
	JOIN spells s ON s.id = sp.spells_id
    JOIN users u2 ON u2.id = sp.to_user_id 
    ORDER BY spells_id;

SELECT * FROM cast_users;

SELECT * FROM cast_users WHERE Ник = 'Cevas';
SELECT * FROM cast_users WHERE Заклинание = 'Animagus Thunderbird';



-- представление для вывода должностей и зарплат пользователей
CREATE or REPLACE VIEW pos_users
AS
SELECT u.nick AS 'Ник', p.name 'Должность', i.name AS 'Предмет/подфорум', p.salary AS 'Зарплата'
FROM position_users pos
	JOIN users u ON u.id = pos.user_id 
	JOIN position p ON pos.position_id = p.id 
	JOIN item i ON i.id = pos.item_id 
    ORDER BY i.name; 

SELECT * FROM pos_users;

SELECT * FROM pos_users WHERE Должность = 'Преподаватель';
SELECT * FROM pos_users WHERE Зарплата = 2000;


/*
 * хранимые процедуры / триггеры
*/

-- триггер для хранения логов заполнения таблицs users
DROP TABLE IF EXISTS logs;
CREATE TABLE logs (
`created_at` DATETIME NOT NULL,
`name_table` VARCHAR(45) NOT NULL,
`id_key` BIGINT(20) NOT NULL,
`name_content` VARCHAR(45) NOT NULL
) ENGINE = ARCHIVE;

DROP TRIGGER IF EXISTS logs_users;
DELIMITER //
CREATE TRIGGER logs_users AFTER INSERT ON users
FOR EACH ROW
BEGIN
	INSERT INTO logs (`created_at`, `name_table`, `id_key`, `name_content`)
	VALUES (NOW(), 'users', NEW.id, NEW.first_name);
END //
DELIMITER ;

-- для проверки
INSERT INTO `users` VALUES (DEFAULT,'Лаура','Гондарева','Volshbtvo','layrina@mail.ru','123456', DEFAULT, DEFAULT);
SELECT * FROM logs;


-- триггер для проверки даты рождения пользователя 
DROP TRIGGER IF EXISTS check_birthday;

DELIMITER //

CREATE TRIGGER check_birthday BEFORE INSERT ON profiles
FOR EACH ROW
	BEGIN
		IF NEW.birthday >= current_date() THEN 
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Родились в будущем?)';
		END IF;
	END//
	
DELIMITER ;

-- для проверки
INSERT INTO profiles (user_id, gender, birthday, city, country) VALUES 
	('11', 'm', '2035-03-07', 'Москва', 'Россия');
	


-- процедура для просмотра какие лекции сдавал юзер

DROP PROCEDURE IF EXISTS sp_lectures_users;

DELIMITER //

CREATE PROCEDURE sp_lectures_users(IN for_user_id BIGINT UNSIGNED)
BEGIN 
	SELECT l.name, i.name
	FROM lectures l
	JOIN lectures_users lu ON lu.lectures_id = l.id 
	JOIN users u ON lu.user_id = u.id
	JOIN item i ON l.item_id = i.id 
	WHERE for_user_id IN (SELECT lu.user_id FROM lectures_users lu2);
END//

DELIMITER ;

CALL sp_lectures_users(1);



-- функция для мониторинга активности общения пользователя (высчитывается по количеству принятых и отправленных сообщений)
DROP FUNCTION IF EXISTS func_user_activity;

DELIMITER // 

CREATE FUNCTION func_user_activity(for_user_id BIGINT UNSIGNED)
RETURNS FLOAT READS SQL DATA 
BEGIN
	DECLARE msg_to_user INT;
	DECLARE msg_from_user INT;
	
	SET msg_to_user = (SELECT COUNT(*) FROM messages WHERE to_user_id = for_user_id);
    SET msg_from_user = (SELECT COUNT(*) FROM messages WHERE from_user_id = for_user_id);

	RETURN msg_to_user + msg_from_user;
END//

DELIMITER ;

SELECT func_user_activity(2) AS 'Количество сообщений у пользователя';