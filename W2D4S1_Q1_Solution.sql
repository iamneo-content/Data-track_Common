
USE retail_analytics;

SELECT
    c.customer_id,
    c.customer_name,
    c.city,
    COUNT(o.order_id) AS total_orders,
    ROUND(SUM(o.order_value), 2) AS total_order_value
FROM
    customers AS c
JOIN
    orders AS o
ON
    c.customer_id = o.customer_id
GROUP BY
    c.customer_id, c.customer_name, c.city
ORDER BY
    total_order_value DESC;
