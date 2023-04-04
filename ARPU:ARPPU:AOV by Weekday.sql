SELECT weekday,
       t2.weekday_number,
       ROUND(revenue::DECIMAL / total_users, 2) arpu,
       ROUND(revenue::DECIMAL / paying_users, 2) arppu,
       ROUND(revenue::DECIMAL / orders, 2) aov
FROM (SELECT to_char(creation_time, 'Day') weekday,
             DATE_PART('isodow', creation_time::DATE) weekday_number,
             SUM(price) revenue
      FROM (SELECT *, UNNEST(product_ids) product_id
            FROM orders
            WHERE order_id NOT IN (SELECT order_id
                                   FROM user_actions
                                   WHERE action = 'cancel_order')) t1
      LEFT JOIN products
      USING(product_id)
      WHERE (creation_time::DATE) BETWEEN '2022-08-26' AND '2022-09-08'
      GROUP BY weekday, weekday_number) t2
LEFT JOIN (SELECT to_char(time, 'Day') weekday,
           DATE_PART('isodow', time::DATE) weekday_number,
           COUNT(DISTINCT user_id) AS total_users
           FROM user_actions
           WHERE (time::DATE) BETWEEN '2022-08-26' AND '2022-09-08'
           GROUP BY weekday, weekday_number) t3
USING (weekday)
LEFT JOIN (SELECT to_char(time, 'Day') weekday,
                  DATE_PART('isodow', time::DATE) weekday_number,
                  COUNT(DISTINCT user_id) as paying_users
           FROM user_actions
           WHERE order_id NOT IN (SELECT order_id
                                  FROM user_actions
                                  WHERE action = 'cancel_order')
                 AND (time::DATE) BETWEEN '2022-08-26' AND '2022-09-08'
           GROUP BY weekday, weekday_number) t4 
USING (weekday)
LEFT JOIN (SELECT to_char(time, 'Day') weekday,
                  DATE_PART('isodow', time::DATE) weekday_number,
                  COUNT(DISTINCT order_id) orders
           FROM   user_actions
           WHERE  order_id NOT IN (SELECT order_id
                                   FROM user_actions
                                   WHERE action = 'cancel_order')
                  AND (time::DATE) BETWEEN '2022-08-26' AND '2022-09-08'
           GROUP BY weekday, weekday_number) t5 
USING (weekday)
ORDER BY weekday_number