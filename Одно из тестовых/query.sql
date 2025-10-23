USE vk;

# Смотрим на количество постов в разное время суток. Делаем вывод, что в ночное время (с 20.00 и до 6.00) посты не публикуются.
# Следовательно, это время можно исключить из анализа.
select
COUNT(case when EXTRACT( HOUR FROM date) <6 THEN 1 END) AS Early,
COUNT(case when EXTRACT( HOUR FROM date) BETWEEN 6 AND 13 THEN 1 END) AS Morning, 
COUNT(case when EXTRACT( HOUR FROM date) BETWEEN 14 AND 20 THEN 1 END) AS Evening,
COUNT(case when EXTRACT( HOUR FROM date) > 20  THEN 1 END) AS Night
from statistic;

# Остальное время (с 6.00 до 20.00) разбиваем на три отрезка и подсчитываем количество постов, общую сумму, мин, макс и среднее значение. 
select 'Утро' as 'Morning', count(likes) as 'Количество', sum(likes) as 'Сумма', round(avg(likes)) as 'Среднее', min(likes) as 'Мин', max(likes) as 'Макс' 
from statistic
where EXTRACT( HOUR FROM date) BETWEEN 6 AND 10
union all
select 'День' as 'Evening', count(likes) as 'Количество', sum(likes) as 'Сумма', round(avg(likes)) as 'Среднее', min(likes) as 'Мин', max(likes) as 'Макс' 
from statistic
where EXTRACT( HOUR FROM date) BETWEEN 11 AND 15
union all
select 'Вечер' as 'Night', count(likes) as 'Количество', sum(likes) as 'Сумма', round(avg(likes)) as 'Среднее', min(likes) as 'Мин', max(likes) as 'Макс' 
from statistic
where EXTRACT( HOUR FROM date) BETWEEN 16 AND 20
# Проанализируем полученную информацию. 
# При меньшем количестве постов (154) в вечернее время наибольший средний показатель (9661), и, соответственно, большее значение по
# мин (466) и макс (168122) количеству лайков. Но по сумме лайков вечер значительно уступает остальным временным отрезкам (1487770). 
# В дневное время больше всего постов (865), но среднее значение (7612) значительно ниже; ниже и мин (307) с макс (123491). 
# Однако здесь самая большая сумма лайков (65841280).
# В утренее время опубликован 371 пост, сумма лайков составляет 3295229. Среднее значение тут среднее во всех смыслах: находится между днём и вечером. 
# По мин и макс количеству примерно на одном уровне с дневными показателями.
# На основании полученных данных можно сделать вывод, что больше всего лайков собирается в дневное время, но это достигается за счёт большего количества постов,
# а не за счёт количества лайков на 1 пост. Вечернее время показывает лучшие результаты в рассчёте количества лаков на 1 пост.


#Посмотрим на статистику по дням недели.
select 'Понедельник' as '1', count(likes) as 'Количество постов', sum(likes) as 'Сумма', round(avg(likes)) as 'Среднее', min(likes) as 'Мин', max(likes) as 'Макс' 
from statistic
where DAYOFWEEK(date) = 1
union all
select 'Вторник' as '2', count(likes) as 'Количество постов', sum(likes) as 'Сумма', round(avg(likes)) as 'Среднее', min(likes) as 'Мин', max(likes) as 'Макс' 
from statistic
where DAYOFWEEK(date) = 2
union all
select 'Среда' as '3', count(likes) as 'Количество постов', sum(likes) as 'Сумма', round(avg(likes)) as 'Среднее', min(likes) as 'Мин', max(likes) as 'Макс' 
from statistic
where DAYOFWEEK(date) = 3
union all
select 'Четверг' as '4', count(likes) as 'Количество постов', sum(likes) as 'Сумма', round(avg(likes)) as 'Среднее', min(likes) as 'Мин', max(likes) as 'Макс' 
from statistic
where DAYOFWEEK(date) = 4
union all
select 'Пятница' as '5', count(likes) as 'Количество постов', sum(likes) as 'Сумма', round(avg(likes)) as 'Среднее', min(likes) as 'Мин', max(likes) as 'Макс' 
from statistic
where DAYOFWEEK(date) = 5
union all
select 'Суббота' as '6', count(likes) as 'Количество постов', sum(likes) as 'Сумма', round(avg(likes)) as 'Среднее', min(likes) as 'Мин', max(likes) as 'Макс' 
from statistic
where DAYOFWEEK(date) = 6
union all
select 'Воскресенье' as '7', count(likes) as 'Количество постов', sum(likes) as 'Сумма', round(avg(likes)) as 'Среднее', min(likes) as 'Мин', max(likes) as 'Макс' 
from statistic
where DAYOFWEEK(date) = 7

# Проанализируем полученную информацию. 
# Наибольшее среднее значение в понедельник и воскресенье. Наименьшее - четверг.
# Сумма лайков больше всего во вторник и субботу. Меньше всего в понедельник.
# Минимальное количество лайков на 1 пост во вторник, максимальное, что самое любопытное, тоже во вторник.
# Очевидно, что при минимальном количестве постов в понедельник, здесь выше значения минимального количества и количества лайков на 1 пост. Сюда же можно отнести и 
# и воскресенье: при небольшом количестве постов средий показатель занимает 2 место.
# Весьма сильно отстаёт четверг, в этот день меньше всего показатель среднего значения.
# Исходя из полученной информации можно сделать вывод, что 'проседает' середина недели (среда и четверг), там показатели количества лайков на 1 пост ниже всего.





