SELECT date, 
       ROUND(revenue::DECIMAL / total_users, 2) arpu,
       ROUND(revenue::DECIMAL / paying_users, 2) arppu,
       ROUND(revenue::DECIMAL / orders, 2) aov
FROM (SELECT (creation_time::DATE) date, SUM(price) revenue
      FROM (SELECT *, UNNEST(product_ids) product_id
            FROM orders
            WHERE order_id NOT IN (SELECT order_id
                                   FROM user_actions
                                   WHERE action = 'cancel_order')) t1
      LEFT JOIN products
      USING(product_id)
      GROUP BY date) t2
LEFT JOIN (SELECT time::DATE AS date,
                  COUNT(DISTINCT user_id) AS total_users
           FROM   user_actions
           GROUP BY date) t3
USING (date)
LEFT JOIN (SELECT time::DATE date,
                  COUNT(distinct user_id) as paying_users
            FROM   user_actions
            WHERE  order_id NOT IN (SELECT order_id
                                    FROM   user_actions
                                    WHERE  action = 'cancel_order')
            GROUP BY date) t4 
USING (date)
LEFT JOIN (SELECT time::DATE date,
                  COUNT(distinct order_id) orders
               FROM   user_actions
               WHERE  order_id NOT IN (SELECT order_id
                                       FROM   user_actions
                                       WHERE  action = 'cancel_order')
               GROUP BY date) t5 
USING (date)