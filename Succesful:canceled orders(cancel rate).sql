SELECT hour::INT, successful_orders, canceled_orders,
       ROUND(canceled_orders::DECIMAL/(successful_orders + canceled_orders), 3) cancel_rate
FROM (SELECT hour, COUNT(order_id) successful_orders
      FROM (SELECT order_id, DATE_PART('hour', creation_time) AS hour
            FROM orders
            WHERE order_id IN (SELECT order_id
                               FROM courier_actions
                               WHERE action = 'deliver_order')) t1
            GROUP BY hour) t2
LEFT JOIN (SELECT hour, COUNT(order_id) canceled_orders
           FROM (SELECT order_id, DATE_PART('hour', creation_time) AS hour
                 FROM orders
                 WHERE order_id IN (SELECT order_id
                                    FROM user_actions
                                    WHERE action = 'cancel_order')) t3
            GROUP BY hour) t4
USING(hour)
ORDER BY hour