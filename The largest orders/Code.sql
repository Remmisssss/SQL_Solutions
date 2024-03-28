-- Задание:

-- Выясните, кто заказывал и доставлял самые большие заказы. Самыми большими считайте заказы с наибольшим числом товаров.

-- Выведите id заказа, id пользователя и id курьера. Также в отдельных колонках укажите возраст пользователя и возраст курьера. 
-- Возраст измерьте числом полных лет, как мы делали в прошлых уроках. 
-- Считайте его относительно последней даты в таблице user_actions — как для пользователей, так и для курьеров. 
-- Колонки с возрастом назовите user_age и courier_age. Результат отсортируйте по возрастанию id заказа.

with one as(SELECT order_id,
                   creation_time,
                   array_length(product_ids, 1),
                   courier_id,
                   user_id
            FROM   orders
                LEFT JOIN courier_actions using(order_id)
                LEFT JOIN user_actions using(order_id)
            WHERE  array_length(product_ids, 1) = (SELECT max(array_length(product_ids, 1))
                                                   FROM   orders)), us as(SELECT user_id,
                              split_part(age((SELECT max(time)::date as time_max
                                       FROM   user_actions), birth_date)::varchar,' ', 1) as user_age
                       FROM   users), cou as (SELECT courier_id,
                              split_part(age((SELECT max(time)::date as time_max
                                       FROM   user_actions), birth_date)::varchar,' ', 1) as courier_age
                       FROM   couriers)
SELECT DISTINCT order_id,
                user_id,
                user_age,
                courier_id,
                courier_age
FROM   one
    LEFT JOIN cou using(courier_id)
    LEFT JOIN us using(user_id)
ORDER BY order_id