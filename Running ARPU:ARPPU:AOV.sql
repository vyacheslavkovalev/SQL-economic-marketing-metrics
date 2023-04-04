SELECT date,
       ROUND(running_revenue::DECIMAL / running_total_users, 2) running_arpu,
       ROUND(running_revenue::DECIMAL / running_paying_users, 2) running_arppu,
       ROUND(running_revenue::DECIMAL / running_total_orders, 2) running_aov
FROM (SELECT date,
             SUM(revenue) OVER (ORDER BY date RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) running_revenue,
             SUM(new_users) OVER (ORDER BY date RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) running_total_users,
             SUM(new_paying_users) OVER (ORDER BY date RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) running_paying_users,
             SUM(total_orders) OVER (ORDER BY date RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) running_total_orders
      FROM (SELECT (creation_time::DATE) date, SUM(price) revenue
            FROM (SELECT *, UNNEST(product_ids) product_id
                  FROM orders
                  WHERE order_id NOT IN (SELECT order_id
                                         FROM user_actions
                                         WHERE action = 'cancel_order')) t1
            LEFT JOIN products
            USING(product_id)
            GROUP BY date) t2
      LEFT JOIN (SELECT date,
                        COUNT(DISTINCT user_id) AS new_users
                 FROM (SELECT MIN(time::DATE) date, user_id
                       FROM user_actions
                       GROUP BY user_id) t3
                 GROUP BY date) t4
      USING (date)
      LEFT JOIN (SELECT date, COUNT(user_id) new_paying_users
                 FROM (SELECT MIN(time::DATE) date, user_id
                       FROM user_actions
                       WHERE order_id NOT IN (SELECT order_id
                                              FROM user_actions
                                              WHERE action = 'cancel_order')
                       GROUP BY user_id) t5
                 GROUP BY date
                 ORDER BY date) t6
      USING (date)
      LEFT JOIN (SELECT time::DATE date,
                        COUNT(DISTINCT order_id) total_orders
                 FROM   user_actions
                 WHERE  order_id NOT IN (SELECT order_id
                                         FROM   user_actions
                                         WHERE  action = 'cancel_order')
                 GROUP BY date) t7
      USING (date)) t8