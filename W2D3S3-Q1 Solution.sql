
USE retail_sales_db;

SELECT
    customer_id,
    customer_name,
    email_id,
    phone_number,
    last_purchase_date,
    total_purchase_value
FROM customer_master
WHERE status = 'Active'
  AND last_purchase_date >= CURDATE() - INTERVAL 30 DAY
ORDER BY last_purchase_date DESC;
