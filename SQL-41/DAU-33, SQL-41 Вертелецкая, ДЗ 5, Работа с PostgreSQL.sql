--=============== МОДУЛЬ 5. РАБОТА С POSTGRESQL =======================================
--= ПОМНИТЕ, ЧТО НЕОБХОДИМО УСТАНОВИТЬ ВЕРНОЕ СОЕДИНЕНИЕ И ВЫБРАТЬ СХЕМУ PUBLIC===========
SET search_path TO public;

--======== ОСНОВНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--Сделайте запрос к таблице payment и с помощью оконных функций добавьте вычисляемые колонки согласно условиям:
--Пронумеруйте все платежи от 1 до N по дате +
--Пронумеруйте платежи для каждого покупателя, сортировка платежей должна быть по дате +
--Посчитайте нарастающим итогом сумму всех платежей для каждого покупателя, сортировка должна быть сперва по дате платежа, а затем по сумме платежа от наименьшей к большей +
--Пронумеруйте платежи для каждого покупателя по стоимости платежа от наибольших к меньшим так, чтобы платежи с одинаковым значением имели одинаковое значение номера.+
--Можно составить на каждый пункт отдельный SQL-запрос, а можно объединить все колонки в одном запросе.

select 
	customer_id, payment_id, payment_date, 
	row_number() over(order by payment_date) row_number_all,
	row_number() over(partition by customer_id order by payment_date) row_number_customers,
	sum(amount) over (partition by customer_id order by payment_date, amount) sum_amount_customers,
	dense_rank() over (partition by customer_id order by amount desc) dense_rank_amount
from payment 

--ЗАДАНИЕ №2
--С помощью оконной функции выведите для каждого покупателя стоимость платежа и стоимость 
--платежа из предыдущей строки со значением по умолчанию 0.0 с сортировкой по дате. +

select
	customer_id,
	payment_date,
	lag(amount, 1, 0.0) over (partition by customer_id order by payment_date),
	amount
from
	payment 
order by 1,2



--ЗАДАНИЕ №3
--С помощью оконной функции определите, на сколько каждый следующий платеж покупателя больше или меньше текущего. +

select
	customer_id,
	payment_date,
	amount,
	lead(amount, 1, 0.0) over (partition by customer_id order by payment_date) lead_amount,
	amount - lead(amount, 1, 0.0) over (partition by customer_id order by payment_date) difference
from
	payment 
order by 1,2

--ЗАДАНИЕ №4
--С помощью оконной функции для каждого покупателя выведите данные о его последней оплате аренды. +

select customer_id, payment_id, payment_date, amount
from 
	(select payment_date, customer_id, payment_id, amount,
		first_value(payment_id) over (partition by customer_id order by payment_date desc)
	from payment) t 
where payment_id = first_value



--======== ДОПОЛНИТЕЛЬНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--С помощью оконной функции выведите для каждого сотрудника сумму продаж за август 2005 года 
--с нарастающим итогом по каждому сотруднику и по каждой дате продажи (без учёта времени) c сортировкой по дате.

select
	staff_id,
	payment_date::date,
	sum(amount) sum_amount,
	sum(sum(amount)) over (partition by staff_id
order by
	payment_date::date)
from
	payment
where
	payment_date::date between '2005-08-01' and '2005-08-31'
group by
	1,
	2

--ЗАДАНИЕ №2
--20 августа 2005 года в магазинах проходила акция: покупатель каждого сотого платежа получал
--дополнительную скидку на следующую аренду. С помощью оконной функции выведите всех покупателей,
--которые в день проведения акции получили скидку +
select
	customer_id,
	payment_date,
	payment_number
from
	(
	select
		customer_id,
		payment_date,
		row_number() over (
		order by payment_id) payment_number
	from
		payment
	where
		payment_date::date = '2005-08-20' ) t
where
	payment_number % 100 = 0



--ЗАДАНИЕ №3
--Для каждой страны определите и выведите одним SQL-запросом покупателей, которые попадают под условия:
-- 1. покупатель, арендовавший наибольшее количество фильмов
-- 2. покупатель, арендовавший фильмов на самую большую сумму
-- 3. покупатель, который последним арендовал фильм

with c1 as (
select
	c.customer_id,
	count(i.film_id),
	sum(p.amount),
	max(r.rental_date),
	c.address_id,
	concat(c.first_name, ' ', c.last_name)
from
	customer c
join rental r on
	r.customer_id = c.customer_id
join inventory i on
	i.inventory_id = r.inventory_id
join payment p on
	p.rental_id = r.rental_id
group by
	c.customer_id),
c2 as (
select
	c1.customer_id,
	c1.concat,
	c2.country_id,
	c1.count,
	c1.sum,
	c1.max,
		max(c1.count) over (partition by c2.country_id) rc,
		max(c1.sum) over (partition by c2.country_id) rs,
		max(c1.max) over (partition by c2.country_id) rm
from
	c1
join address a on
	c1.address_id = a.address_id
join city c2 on
	c2.city_id = a.city_id)
select
	c.country as "Страна", 
	string_agg(c2.concat::text, ', ') filter (
	where count = rc) as "Покупатель, арендовавший наибольшее количество фильмов",
	string_agg(c2.concat::text, ', ') filter (
	where sum = rs) as "Покупатель, арендовавший фильмов на самую большую сумму",
	string_agg(c2.concat::text, ', ') filter (
	where max = rm) as "Покупатель, который последним арендовал фильм"
from
	country c
left join c2 on
	c2.country_id = c.country_id
group by
	c.country
order by
	c.country

