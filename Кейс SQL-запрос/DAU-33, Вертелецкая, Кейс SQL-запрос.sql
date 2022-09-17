--ЗАДАНИЕ
--Вы — аналитик данных. Руководитель дал вам задание поработать с таблицей logs действий пользователей (user_id, event, event_time, value). Действия пользователей поделены на сессии - последовательности событий, в которых между соседними по времени событиями промежуток не более 5 минут. Т.е. длина всей сессии может быть гораздо больше 5 минут, но между каждыми последовательными событиями не должно быть более 5 минут.
--Поле event может принимать разные значения, в том числе ’template_selected’ (пользователь выбрал некий шаблон). В случае, если event=’template_selected’, то в value записано название этого шаблона (например, ’pop_art_style’).	
--Напишите SQL-запрос, выводящий 5 шаблонов, которые чаще всего применяются юзерами 2 и более раза подряд в течение одной сессии.

--Контакты: Вертелецкая Александра alexandraver18@gmail.com
--Затраченное время < 3 ч.

--ИТОГОВЫЙ ВАРИАНТ ЗАПРОСА 
with cte1 as (
	select *
	from (select *,
		lead(event_time, 1) over (partition by user_id order by event_time) lead_event_time,
		lead(event_time, 1) over (partition by user_id order by event_time) - event_time difference
		from logs_tz_an1) t1
	where difference between '00:00:00' and '00:05:00')
select *
from (select "event", value, count(value) c_val
	from cte1
	group by 1,2) t 
where "event" like 'template_selected' and c_val >= 2  
limit 5; 

--ХОД РЕШЕНИЯ ПОСТАВЛЕННОЙ ЗАДАЧИ
--создание таблицы logs_tz_an1
create table logs_tz_an1 (
	logs_id serial primary key,
	user_id int not null,
	event varchar(60),
	event_time timestamp,
	value varchar(60)
);

--заполнение тестовыми данными
insert into logs_tz_an1 (user_id, event, event_time, value)
values 
	(269, 'template_selected', '2005-05-26 22:04:30.000', 'pop_art_style'),
	(269, 'wait', '2005-05-26 22:08:30.000', ''),
	(378, 'add_file', '2005-05-28 19:40:33.000', 'test.txt'),
	(213, 'template_selected', '2005-06-01 22:12:39.000', 'rock_style'),
	(300, 'comment', '2005-06-03 01:43:41.000', 'cool'),
	(669, 'print_file', '2005-06-04 04:33:21.000', 'test2.csv'),
	(269, 'add_file', '2005-06-04 04:34:21.000', 'test3.csv'),
	(378, 'template_selected', '2005-06-10 20:34:53.000', 'pop_art_style'),
	(457, 'comment', '2005-06-17 23:33:46.000', 'i think...')
	
--добавление данных в таблицу
insert into logs_tz_an1 (user_id, event, event_time, value)
values 
	(669, 'template_selected', '2005-06-17 23:34:30.000', 'pop_art_style'),
	(269, 'wait', '2005-06-26 22:08:30.000', ''),
	(378, 'add_file', '2005-06-28 19:40:33.000', 'test.txt'),
	(213, 'template_selected', '2005-07-01 22:12:39.000', 'rock_style'),
	(378, 'comment', '2005-07-03 01:43:41.000', 'cool'),
	(669, 'print_file', '2005-07-04 04:33:21.000', 'test2.csv'),
	(269, 'add_file', '2005-07-04 04:34:21.000', 'test3.csv'),
	(269, 'template_selected', '2005-07-04 04:35:53.000', 'pop_art_style'),
	(457, 'comment', '2005-07-17 23:33:46.000', 'i think...')
	
--добавление данных в таблицу
insert into logs_tz_an1 (user_id, event, event_time, value)
values 
	(669, 'template_selected', '2005-06-17 23:38:30.000', 'pop_art_style'),
	(269, 'wait', '2005-06-26 22:09:30.000', ''),
	(378, 'add_file', '2005-06-28 19:43:33.000', 'test.txt'),
	(213, 'template_selected', '2005-07-01 22:15:39.000', 'rock_style'),
	(378, 'comment', '2005-07-03 01:49:41.000', 'cool'),
	(669, 'print_file', '2005-07-04 04:39:21.000', 'test2.csv'),
	(269, 'add_file', '2005-07-04 04:45:21.000', 'test3.csv'),
	(269, 'template_selected', '2005-07-04 04:39:53.000', 'pop_art_style'),
	(457, 'comment', '2005-07-17 23:36:46.000', 'i think...')

--Запрос без учёта времени сессии
select *
from (select "event", value, count(value) c_val
	from logs_tz_an1
	group by 1,2) t 
where "event" like 'template_selected' and c_val >= 2  
limit 5;

--Запрос на сессии, продолжительностью более 5 минут
select *
from (select *,
	lead(event_time, 1) over (partition by user_id order by event_time) lead_event_time,
	lead(event_time, 1) over (partition by user_id order by event_time) - event_time difference
	from logs_tz_an1) t1
where difference between '00:00:00' and '00:05:00';

--Объединение запросов (ИТОГОВЫЙ ВАРИАНТ ЗАПРОСА)
with cte1 as (
	select *
	from (select *,
		lead(event_time, 1) over (partition by user_id order by event_time) lead_event_time,
		lead(event_time, 1) over (partition by user_id order by event_time) - event_time difference
		from logs_tz_an1) t1
	where difference between '00:00:00' and '00:05:00')
select *
from (select "event", value, count(value) c_val
	from cte1
	group by 1,2) t 
where "event" like 'template_selected' and c_val >= 2  
limit 5; 




