SELECT date, revenue, 
       SUM(revenue) OVER (ORDER BY date RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) total_revenue,
       ROUND(100 * (revenue - LAG(revenue) OVER (ORDER BY date))/LAG(revenue) OVER (ORDER BY date), 2) revenue_change
FROM (SELECT (creation_time::DATE) date, SUM(price) revenue
      FROM (SELECT *, UNNEST(product_ids) product_id
            FROM orders
            WHERE order_id NOT IN (SELECT order_id
                                   FROM user_actions
                                   WHERE action = 'cancel_order')) t1
      LEFT JOIN products
      USING(product_id)
      GROUP BY date) t2