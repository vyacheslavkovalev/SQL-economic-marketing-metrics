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
    SELECT date, COUNT(user_id) new_users
    FROM (SELECT MIN(time::DATE) date, user_id
        FROM user_actions
        GROUP BY user_id) t1
    GROUP BY date
    ),
    subquery_5 AS (
    SELECT date, COUNT(courier_id) new_couriers
    FROM (SELECT MIN(time::DATE) date, courier_id
        FROM courier_actions
        GROUP BY courier_id) t2
    GROUP BY date
    ),
    subquery_6 AS (
    SELECT *, SUM(new_users) OVER (ORDER BY date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) total_users,
        SUM(new_couriers) OVER (ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) total_couriers
    FROM subquery_4
    FULL JOIN subquery_5
    USING(date)
    )
    
SELECT date, paying_users, active_couriers, 
ROUND((paying_users::DECIMAL/total_users)*100, 2) paying_users_share,
ROUND((active_couriers::DECIMAL/total_couriers)*100, 2) active_couriers_share
FROM subquery_3
FULL JOIN subquery_6
USING(date)