SELECT date,
       revenue,
       costs,
       tax,
       revenue - costs - tax gross_profit,
       SUM(revenue) OVER(ORDER BY date RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) total_revenue,
       SUM(costs) OVER(ORDER BY date RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) total_costs,
       SUM(tax) OVER(ORDER BY date RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) total_tax,
       SUM(revenue - costs - tax) OVER(ORDER BY date RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) total_gross_profit,
       ROUND(100*(revenue - costs - tax)/revenue, 2) gross_profit_ratio,
       ROUND(100*SUM(revenue - costs - tax) OVER(ORDER BY date RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)/SUM(revenue) OVER(ORDER BY date RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW), 2) total_gross_profit_ratio
FROM (SELECT (creation_time::DATE) date, SUM(price) revenue
      FROM (SELECT *, UNNEST(product_ids) product_id
            FROM orders
            WHERE order_id NOT IN (SELECT order_id
                                   FROM user_actions
                                   WHERE action = 'cancel_order')) t1
      LEFT JOIN products
      USING(product_id)
      GROUP BY date) t2
LEFT JOIN (SELECT date, SUM(tax) tax
           FROM (SELECT date, name,
                        CASE
                        WHEN name in ('сахар', 'сухарики', 'сушки', 'семечки', 
                                      'масло льняное', 'виноград', 'масло оливковое', 
                                       'арбуз', 'батон', 'йогурт', 'сливки', 'гречка', 
                                       'овсянка', 'макароны', 'баранина', 'апельсины', 
                                       'бублики', 'хлеб', 'горох', 'сметана', 'рыба копченая', 
                                       'мука', 'шпроты', 'сосиски', 'свинина', 'рис', 
                                       'масло кунжутное', 'сгущенка', 'ананас', 'говядина', 
                                       'соль', 'рыба вяленая', 'масло подсолнечное', 'яблоки', 
                                       'груши', 'лепешка', 'молоко', 'курица', 'лаваш', 'вафли', 'мандарины') THEN ROUND(price/110*10, 2)
                        ELSE ROUND(price/120*20, 2)
                        END AS tax
                 FROM (SELECT (creation_time::DATE) date, UNNEST(product_ids) product_id
                       FROM orders
                       WHERE order_id NOT IN (SELECT order_id
                                              FROM user_actions
                                              WHERE action = 'cancel_order')) t3
                LEFT JOIN products
                USING(product_id)) t4
           GROUP BY date) t5
USING(date)
LEFT JOIN (SELECT date,
                  CASE
                  WHEN DATE_PART('month', date) = 8 THEN 120000+140*packed_orders+150*delivered_orders+400*COALESCE(bonus_couriers,0)
                  ELSE 150000+115*packed_orders+150*delivered_orders+500*COALESCE(bonus_couriers,0)
                  END AS costs
            FROM (SELECT date, packed_orders, delivered_orders, bonus_couriers
                  FROM (SELECT (creation_time::DATE) date, COUNT(order_id) packed_orders
                        FROM orders
                        WHERE order_id NOT IN (SELECT order_id
                                               FROM user_actions
                                               WHERE action = 'cancel_order')
                        GROUP BY creation_time::DATE) t6
            LEFT JOIN (SELECT (time::DATE) date, COUNT(order_id) delivered_orders
                       FROM courier_actions
                       WHERE action = 'deliver_order'
                       GROUP BY date) t7
            USING(date)
            LEFT JOIN (SELECT date, COUNT(courier_id) bonus_couriers
                       FROM (SELECT (time::DATE) date, courier_id, COUNT(order_id) delivered_courier_orders
                             FROM courier_actions
                             WHERE action = 'deliver_order'
                             GROUP BY courier_id, date) t8
                       WHERE delivered_courier_orders >= 5
                       GROUP BY date) t9
            USING(date)) t10) t11
USING(date)
ORDER BY date