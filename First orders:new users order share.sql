SELECT date, orders, first_orders, new_users_orders,
       ROUND(100 * first_orders::DECIMAL / orders, 2) first_orders_share,
       ROUND(100 * new_users_orders::DECIMAL / orders, 2) new_users_orders_share
FROM (SELECT t1.date, SUM(COALESCE(orders, 0))::INT new_users_orders
      FROM (SELECT MIN(time::DATE) date, user_id
            FROM user_actions
            GROUP BY user_id
            ORDER BY user_id) t1
      FULL JOIN (SELECT time::DATE AS date, user_id,
                        COUNT(DISTINCT order_id) AS orders
                 FROM   user_actions
                 WHERE  order_id NOT IN (SELECT order_id
                                         FROM   user_actions
                                         WHERE  action = 'cancel_order')
                 GROUP BY user_id, date) t2
      USING (user_id, date)
      WHERE t1.date IS NOT NULL
      GROUP BY t1.date
      ORDER BY date) t3
LEFT JOIN (SELECT date, COUNT(user_id) first_orders
           FROM (SELECT MIN(time::DATE) date, user_id
                 FROM user_actions
                 WHERE order_id NOT IN (SELECT order_id
                                        FROM   user_actions
                                        WHERE  action = 'cancel_order')
                 GROUP BY user_id) t4
           GROUP BY date
           ORDER BY date) t5
USING (date)
LEFT JOIN (SELECT time::DATE AS date,
                  COUNT(DISTINCT order_id) AS orders
           FROM   user_actions
           WHERE  order_id NOT IN (SELECT order_id
                                   FROM   user_actions
                                   WHERE  action = 'cancel_order')
           GROUP BY date) t6
USING (date)