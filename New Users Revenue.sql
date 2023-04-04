SELECT date, revenue, new_users_revenue,
       ROUND(100 * new_users_revenue::DECIMAL/revenue, 2) new_users_revenue_share,
       ROUND(100 * (revenue - new_users_revenue)::DECIMAL/revenue, 2) old_users_revenue_share
FROM (SELECT date, SUM(new_users_revenue) new_users_revenue
      FROM (SELECT MIN(time::DATE) date, user_id
            FROM user_actions
            GROUP BY user_id) t1
      LEFT JOIN (SELECT time::DATE AS date, user_id, SUM(order_price) new_users_revenue
                 FROM user_actions
                 LEFT JOIN (SELECT order_id, SUM(price) order_price
                            FROM (SELECT *, UNNEST(product_ids) product_id
                                  FROM orders
                                  WHERE order_id NOT IN (SELECT order_id
                                                         FROM user_actions
                                                         WHERE action = 'cancel_order')) t2
                            LEFT JOIN products
                            USING(product_id)
                            GROUP BY order_id) t3
                 USING (order_id)
                 WHERE order_id NOT IN (SELECT order_id
                                        FROM user_actions
                                        WHERE action = 'cancel_order')
                 GROUP BY user_id, date) t4
      USING (user_id, date)
      GROUP BY date
      ORDER BY date) t5
LEFT JOIN (SELECT (creation_time::DATE) date, SUM(price) revenue
           FROM (SELECT *, UNNEST(product_ids) product_id
                 FROM orders
                 WHERE order_id NOT IN (SELECT order_id
                                        FROM user_actions
                                        WHERE action = 'cancel_order')) t6
                 LEFT JOIN products
                 USING(product_id)
                 GROUP BY date) t7
USING(date)