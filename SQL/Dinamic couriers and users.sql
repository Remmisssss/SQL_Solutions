with new_user as(
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

select date, new_users, new_couriers, total_users,total_couriers,
    round(new_users/lag(new_users) over()::decimal*100 - 100,2) as new_users_change,
    round(new_couriers/lag(new_couriers) over()::decimal*100 - 100,2) as new_couriers_change,
    round(total_users/lag(total_users) over()::decimal*100 - 100,2) as total_users_growth,
    round(total_couriers/lag(total_couriers) over()::decimal*100 - 100,2) as total_couriers_growth
from 
    (select date, new_users, new_couriers, 
    sum(new_users) over(order by date)::int as total_users,
    sum(new_couriers) over(order by date)::int as total_couriers
    from new_user
    left join new_courier using(date)) a
order by date
