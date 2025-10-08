-- Active: 1759911087247@@127.0.0.1@3306@raw_customer_database
USE raw_customer_database;

INSERT INTO dim_customer (customer_code, customer_name, city)
VALUES ('UNK', 'Unknown', 'Unknown');

INSERT INTO dim_product (product_code, product_name, category)
VALUES ('UNK', 'Unknown', 'Unknown');

UPDATE dim_customer
SET customer_name = IFNULL(customer_name, 'Unknown'),
    city = IFNULL(city, 'Unknown');

UPDATE dim_product
SET product_name = IFNULL(product_name, 'Unknown'),
    category = IFNULL(category, 'Unknown');

INSERT INTO fact_sales (sales_date, customer_key, product_key, quantity, amount)
SELECT
  s.sales_date,
  IFNULL(dc.customer_key, (SELECT customer_key FROM dim_customer WHERE customer_code = 'UNK')),
  IFNULL(dp.product_key,  (SELECT product_key  FROM dim_product  WHERE product_code  = 'UNK')),
  IFNULL(s.quantity, 0),
  IFNULL(s.amount, 0.00)
FROM stg_sales s
LEFT JOIN dim_customer dc ON s.customer_code = dc.customer_code
LEFT JOIN dim_product  dp ON s.product_code  = dp.product_code;

SELECT * FROM fact_sales;