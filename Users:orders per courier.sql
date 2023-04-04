WITH subquery_1 AS(
    SELECT (time::DATE) date, COUNT(DISTINCT user_id) paying_users
    FROM user_actions
    WHERE order_id NOT in (
        SELECT order_id
        FROM user_actions
        WHERE action = 'cancel_order')
    GROUP BY date),
    subquery_2 AS (
    SELECT (time::DATE) date, COUNT(DISTINCT courier_id) active_couriers
    FROM courier_actions
    WHERE order_id in (
        SELECT order_id
        FROM courier_actions
        WHERE action = 'deliver_order')
    GROUP BY date),
    subquery_3 AS (
    SELECT *
    FROM subquery_1
    LEFT JOIN subquery_2
    USING(date)
    ),
    subquery_4 AS (
    SELECT time::DATE AS date, COUNT(DISTINCT order_id) payed_orders
    FROM user_actions
    WHERE order_id NOT IN (SELECT order_id
                           FROM user_actions
                           WHERE action = 'cancel_order')
    GROUP BY date)
    
SELECT date,
       ROUND((paying_users::DECIMAL/active_couriers), 2) users_per_courier,
       ROUND((payed_orders::DECIMAL/active_couriers), 2) orders_per_courier
FROM subquery_3
LEFT JOIN subquery_4
USING(date)