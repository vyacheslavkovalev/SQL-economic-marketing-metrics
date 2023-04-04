SELECT date, ROUND(AVG(duration)/60)::INT minutes_to_deliver
FROM (SELECT MAX(time::DATE) AS date, order_id, EXTRACT(epoch FROM MAX(time) - MIN(time)) duration
      FROM courier_actions
      WHERE order_id NOT IN (SELECT order_id
                             FROM user_actions
                             WHERE action = 'cancel_order')
      GROUP BY order_id) t1
GROUP BY date
ORDER BY date