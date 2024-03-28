-- Задание:

-- Для каждой записи в таблице user_actions с помощью оконных функций и предложения FILTER посчитайте, 
-- сколько заказов сделал и сколько отменил каждый пользователь на момент совершения нового действия.

-- Иными словами, для каждого пользователя в каждый момент времени посчитайте две накопительные суммы — числа оформленных и числа отменённых заказов. 
-- Если пользователь оформляет заказ, то число оформленных им заказов увеличивайте на 1, если отменяет — увеличивайте на 1 количество отмен.
-- Колонки с накопительными суммами числа оформленных и отменённых заказов назовите соответственно created_orders и canceled_orders. 
-- На основе этих двух колонок для каждой записи пользователя посчитайте показатель cancel_rate, т.е. долю отменённых заказов в общем количестве оформленных заказов. 
-- Значения показателя округлите до двух знаков после запятой. Колонку с ним назовите cancel_rate.
-- В результате у вас должны получиться три новые колонки с динамическими показателями, которые изменяются во времени с каждым новым действием пользователя.
-- В результирующей таблице отразите все колонки из исходной таблицы вместе с новыми колонками. 
-- Отсортируйте результат по колонкам user_id, order_id, time — по возрастанию значений в каждой.
-- Добавьте в запрос оператор LIMIT и выведите только первые 1000 строк результирующей таблицы.

SELECT user_id,
       order_id,
       action,
       time,
       created_orders,
       canceled_orders,
       round(canceled_orders/created_orders::decimal, 2) as cancel_rate
FROM   (SELECT user_id,
               order_id,
               action,
               time,
               case when action = 'create_order' then count(order_id) filter (WHERE action = 'create_order') OVER(PARTITION BY user_id
                                                                                                                  ORDER BY order_id)
               else count(order_id) filter (WHERE action = 'create_order') OVER(PARTITION BY user_id
                                                                                     ORDER BY time) end as created_orders,
               case when action = 'cancel_order' then count(order_id) filter (WHERE action = 'cancel_order') OVER(PARTITION BY user_id
                                                                                                                  ORDER BY time)
               else count(order_id) filter (WHERE action = 'cancel_order') OVER(PARTITION BY user_id
                                                                                     ORDER BY time) end as canceled_orders
        FROM   user_actions) a
ORDER BY user_id, order_id, time limit 1000