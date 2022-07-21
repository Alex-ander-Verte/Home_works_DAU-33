--=============== МОДУЛЬ 6. POSTGRESQL =======================================
--= ПОМНИТЕ, ЧТО НЕОБХОДИМО УСТАНОВИТЬ ВЕРНОЕ СОЕДИНЕНИЕ И ВЫБРАТЬ СХЕМУ PUBLIC===========
SET search_path TO public;

--======== ОСНОВНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--Напишите SQL-запрос, который выводит всю информацию о фильмах 
--со специальным атрибутом "Behind the Scenes".

explain analyze --67.50
select
	film_id,
	title,
	special_features
from
	film
where
	special_features && array['Behind the Scenes'];

--ЗАДАНИЕ №2
--Напишите еще 2 варианта поиска фильмов с атрибутом "Behind the Scenes",
--используя другие функции или операторы языка SQL для поиска значения в массиве.

explain analyze --77.50
select
	film_id,
	title,
	special_features
from
	film
where
	'Behind the Scenes' = any(special_features);

explain analyze --67.50
select
	film_id,
	title,
	special_features
from
	film
where
	array['Behind the Scenes'] <@ special_features;

explain analyze --451.25
select
	film_id,
	title,
	special_features
from
	film
where
	'Behind the Scenes' in (
	select
		unnest(special_features));

--ЗАДАНИЕ №3
--Для каждого покупателя посчитайте сколько он брал в аренду фильмов 
--со специальным атрибутом "Behind the Scenes.

--Обязательное условие для выполнения задания: используйте запрос из задания 1, 
--помещенный в CTE. CTE необходимо использовать для решения задания.

--Доработанная версия запроса с использованием ОТВ
explain analyze --807,82
with cte1 as (
	select
		film_id,
		title,
		special_features
	from
		film
	where
		special_features && array['Behind the Scenes']
)
select customer_id, count(r.rental_id) film_count
from cte1
join inventory i on
	cte1.film_id = i.film_id
join rental r on
	i.inventory_id = r.inventory_id 
group by
	1
order by
	1;
	
--Старая версия запроса, отправленного на доработку
explain analyze --822.26
with cte1 as (
select
	f.film_id,
	title,
	special_features,
	r.customer_id,
	r.rental_id
from
	film f
join inventory i on
	f.film_id = i.film_id
join rental r on
	i.inventory_id = r.inventory_id
where
	special_features && array['Behind the Scenes']
)
select customer_id, count(rental_id) film_count
from cte1
group by
	1
order by
	1;



--ЗАДАНИЕ №4
--Для каждого покупателя посчитайте сколько он брал в аренду фильмов
-- со специальным атрибутом "Behind the Scenes".

--Обязательное условие для выполнения задания: используйте запрос из задания 1,
--помещенный в подзапрос, который необходимо использовать для решения задания.

--Доработанная версия запроса с использованием подзапроса
explain analyze --675,47
select customer_id, count(r.rental_id) film_count
from (
	select
		film_id,
		title,
		special_features
	from
		film
	where
		special_features && array['Behind the Scenes']
) t
join inventory i on
	t.film_id = i.film_id
join rental r on
	i.inventory_id = r.inventory_id 
group by
	1
order by
	1;

--Старая версия запроса, отправленного на доработку
explain analyze --675.28
select
	customer_id ,
	count(rental_id) film_count
from
	(
	select
		f.film_id,
		title,
		special_features,
		r.customer_id,
		r.rental_id
	from
		film f
	join inventory i on
		f.film_id = i.film_id
	join rental r on
		i.inventory_id = r.inventory_id
	where
		special_features && array['Behind the Scenes']
) t
group by
	1
order by
	1;

--ЗАДАНИЕ №5
--Создайте материализованное представление с запросом из предыдущего задания
--и напишите запрос для обновления материализованного представления

SET search_path TO Verteletskaya_A_sql41;

create materialized view film_count as
	select
	customer_id ,
	count(rental_id) film_count
from
	(
	select
		f.film_id,
		title,
		special_features,
		r.customer_id,
		r.rental_id
	from
		public.film f
	join public.inventory i on
		f.film_id = i.film_id
	join public.rental r on
		i.inventory_id = r.inventory_id
	where
		special_features && array['Behind the Scenes']
	) t
group by
	1
order by
	1
with no data;

refresh materialized view film_count;

--ЗАДАНИЕ №6
--С помощью explain analyze проведите анализ скорости выполнения запросов
-- из предыдущих заданий и ответьте на вопросы:

--1. Каким оператором или функцией языка SQL, используемых при выполнении домашнего задания, 
--   поиск значения в массиве происходит быстрее
--2. какой вариант вычислений работает быстрее: 
--   с использованием CTE или с использованием подзапроса

1. Поиск значения в массиве происходит быстрее при использовании && или <@

2. С использованием подзапроса вычисления быстрее, чем с ОТВ


--======== ДОПОЛНИТЕЛЬНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--Выполняйте это задание в форме ответа на сайте Нетологии

Прикреплю отдельный файл к ДЗ

--ЗАДАНИЕ №2
--Используя оконную функцию выведите для каждого сотрудника
--сведения о самой первой продаже этого сотрудника.
SET search_path TO public;

select
	distinct on
	(p.staff_id) p.staff_id, 
		f.film_id, 
		f.title, 
		p.amount, 
		first_value (p.payment_date) over (partition by p.staff_id
order by
	p.payment_date), 
		c.last_name customer_last_name, 
		c.first_name customer_first_name
from
	payment p
join rental r on
	p.rental_id = r.rental_id
join inventory i on
	r.inventory_id = i.inventory_id
join film f on
	i.film_id = f.film_id
join customer c on
	p.customer_id = c.customer_id
group by
	1,
	2,
	3,
	4,
	p.payment_date ,
	6,
	7;

--ЗАДАНИЕ №3
--Для каждого магазина определите и выведите одним SQL-запросом следующие аналитические показатели:
-- 1. день, в который арендовали больше всего фильмов (день в формате год-месяц-день)
-- 2. количество фильмов взятых в аренду в этот день
-- 3. день, в который продали фильмов на наименьшую сумму (день в формате год-месяц-день)
-- 4. сумму продажи в этот день

with cte1 as (
	select distinct on (s.store_id) s.store_id, rental_date::date, count(rental_id)
	from rental r
	join staff s on r.staff_id = s.staff_id 
	group by 1, 2
	order by 1, 3 desc
),
cte2 as (
	select distinct on (s.store_id) s.store_id, payment_date::date, sum(amount) 
	from payment p
	join staff s on p.staff_id = s.staff_id 
	group by 1, 2
	order by 1, 3
)
select cte1.store_id as "ID магазина", 
	rental_date as "День, в который арендовали больше всего фильмов",
	count as "Количество фильмов, взятых в аренду в этот день",
	payment_date as "День, в который продали фильмов на наименьшую сумму",
	sum as "Сумма продажи в этот день"
from cte1
full join cte2 on cte1.store_id = cte2.store_id;

