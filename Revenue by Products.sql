SELECT product_name, SUM(revenue) revenue, SUM(share_in_revenue) share_in_revenue
FROM (SELECT name AS product_name, revenue,
             ROUND((revenue/SUM(revenue) OVER())*100, 2) share_in_revenue
      FROM (SELECT CASE
                   WHEN ROUND((SUM(price)/SUM(SUM(price)) OVER())*100, 2) < 0.5 THEN 'ДРУГОЕ'
                   ELSE name
                   END AS name,
                   SUM(price) revenue
            FROM (SELECT *, UNNEST(product_ids) product_id
                  FROM orders
                  WHERE order_id NOT IN (SELECT order_id
                                         FROM user_actions
                                         WHERE action = 'cancel_order')) t1
            LEFT JOIN products
            USING(product_id)
       GROUP BY name) t2) t3
GROUP BY product_name
ORDER BY revenue DESC