WITH subquery_1 AS(
    SELECT MIN(time::DATE) date, user_id
    FROM user_actions
    GROUP BY user_id
    ),
    subquery_2 AS (
    SELECT MIN(time::DATE) date, courier_id
    FROM courier_actions
    GROUP BY courier_id
    ),
    subquery_3 AS (
    SELECT date, COUNT(user_id) new_users
    FROM subquery_1
    GROUP BY date
    ),
    subquery_4 AS (
    SELECT date, COUNT(courier_id) new_couriers
    FROM subquery_2
    GROUP BY date
    ),
    subquery_5 AS (
    SELECT *, SUM(new_users) OVER (ORDER BY date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) total_users,
        SUM(new_couriers) OVER (ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) total_couriers
    FROM subquery_3
    FULL JOIN subquery_4
    USING(date)
    )

SELECT date, new_users, new_couriers, total_users::INT, total_couriers::INT,
    ROUND(((new_users - LAG(new_users) OVER ()::DECIMAL) / LAG(new_users) OVER ()) * 100, 2) new_users_change,
    ROUND(((new_couriers - LAG(new_couriers) OVER ()::DECIMAL) / LAG(new_couriers) OVER ()) * 100, 2) new_couriers_change,
    ROUND(((total_users - LAG(total_users) OVER ()) / LAG(total_users) OVER ()) * 100, 2) total_users_growth,
    ROUND(((total_couriers - LAG(total_couriers) OVER ()) / LAG(total_couriers) OVER ()) * 100, 2) total_couriers_growth
FROM subquery_5