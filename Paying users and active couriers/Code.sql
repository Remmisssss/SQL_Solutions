-- Задание:
-- Для каждого дня, представленного в таблицах user_actions и courier_actions, рассчитайте следующие показатели:

    -- Число платящих пользователей.
    -- Число активных курьеров.
    -- Долю платящих пользователей в общем числе пользователей на текущий день.
    -- Долю активных курьеров в общем числе курьеров на текущий день.

-- Колонки с показателями назовите соответственно paying_users, active_couriers, paying_users_share, active_couriers_share. Колонку с датами назовите date.
-- Проследите за тем, чтобы абсолютные показатели были выражены целыми числами. Все показатели долей необходимо выразить в процентах. 
-- При их расчёте округляйте значения до двух знаков после запятой.

-- Результат должен быть отсортирован по возрастанию даты. 

-- Поля в результирующей таблице: date, paying_users, active_couriers, paying_users_share, active_couriers_share

with pay_users as(
    select time::date as date,count(distinct user_id) as paying_users
    from user_actions
    where order_id not in (select order_id from user_actions where action = 'cancel_order')
    group by time::date),
act_couriers as(
    select time::date as date, count(distinct courier_id) as active_couriers from courier_actions
    where order_id in(select order_id from courier_actions where action = 'deliver_order') 
    group by time::date),
new_user as(
    select date::date, count(user_id) as new_users from (select 
        time as date, 
        user_id, 
        min(time) over(partition by user_id) as min_user_time
    from user_actions) a
    where date = min_user_time
    group by date::date),
new_courier as(
    select date::date, count(courier_id) as new_couriers from (select 
        time as date, 
        courier_id, 
        min(time) over(partition by courier_id) as min_courier_time
    from courier_actions) a
    where date = min_courier_time
    group by date::date)

select date, paying_users, active_couriers, 
    round(paying_users/sum(new_users) over(order by date)*100,2)::decimal as paying_users_share,
    round(active_couriers/sum(new_couriers) over(order by date)*100,2)::decimal as active_couriers_share
from new_user
left join new_courier using(date)
left join act_couriers using(date)
left join pay_users using(date)
order by date

