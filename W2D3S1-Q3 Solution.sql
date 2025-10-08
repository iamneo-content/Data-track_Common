
USE oltp_bookstore;

SELECT 
  c.name AS customer_name,
  ROUND(SUM(oi.quantity * p.price), 2) AS total_sales
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
GROUP BY c.name
ORDER BY total_sales DESC;
