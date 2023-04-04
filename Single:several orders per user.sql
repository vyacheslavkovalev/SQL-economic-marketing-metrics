SELECT date,
       ROUND(100 * single_order_users::DECIMAL / paying_users, 2) single_order_users_share,
       ROUND(100 * several_orders_users::DECIMAL / paying_users, 2) several_orders_users_share
FROM (SELECT date,
      COUNT(DISTINCT user_id) single_order_users
      FROM (SELECT time::DATE AS date, user_id, COUNT(DISTINCT order_id) payed_orders
            FROM   user_actions
            WHERE  order_id NOT IN (SELECT order_id
                                    FROM   user_actions
                                    WHERE  action = 'cancel_order')
            GROUP BY user_id, date
            HAVING COUNT(DISTINCT order_id) = 1) t1
      GROUP BY date) t2
LEFT JOIN (SELECT date,
                  COUNT(DISTINCT user_id) several_orders_users
           FROM (SELECT time::DATE AS date, user_id, COUNT(DISTINCT order_id) payed_orders
                 FROM   user_actions
                 WHERE  order_id NOT IN (SELECT order_id
                                         FROM   user_actions
                                         WHERE  action = 'cancel_order')
                 GROUP BY user_id, date
                 HAVING COUNT(DISTINCT order_id) > 1) t3
           GROUP BY date) t4
USING (date)
LEFT JOIN (SELECT time::DATE AS date,
                  COUNT(DISTINCT user_id) AS paying_users
           FROM   user_actions
           WHERE  order_id NOT IN (SELECT order_id
                                   FROM   user_actions
                                   WHERE  action = 'cancel_order')
           GROUP BY date) t5
USING (date)