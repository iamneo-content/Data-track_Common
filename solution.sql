
DROP DATABASE IF EXISTS retail_dw;
CREATE DATABASE retail_dw;
USE retail_dw;

DROP TABLE IF EXISTS stg_sales;
CREATE TABLE stg_sales (
  order_id   INT NULL,
  order_date DATE NULL,
  region     VARCHAR(50) NULL,
  product    VARCHAR(50) NULL,
  qty        INT NULL,
  price      DECIMAL(10,2) NULL
);

LOAD DATA LOCAL INFILE '/home/coder/project/workspace/Project1/data/retail_sales_raw.csv' 
INTO TABLE stg_sales 
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' 
LINES TERMINATED BY '\n' 
IGNORE 1 LINES 
(order_id, order_date, region, product, qty, price);

DROP TABLE IF EXISTS int_sales;
CREATE TABLE int_sales (
  order_id    INT,
  order_date  DATE,
  region_code VARCHAR(16),
  product     VARCHAR(50),
  qty         INT,
  price       DECIMAL(10,2),
  total_value DECIMAL(12,2)
);

INSERT INTO int_sales (order_id, order_date, region_code, product, qty, price, total_value)
SELECT
  s.order_id,
  s.order_date,
  CASE
    WHEN s.region IS NULL THEN 'UNKNOWN'
    WHEN UPPER(TRIM(s.region)) IN ('NORTH','N') THEN 'NORTH'
    WHEN UPPER(TRIM(s.region)) IN ('SOUTH','S') THEN 'SOUTH'
    WHEN UPPER(TRIM(s.region)) IN ('EAST','E')  THEN 'EAST'
    WHEN UPPER(TRIM(s.region)) IN ('WEST','W')  THEN 'WEST'
    ELSE 'UNKNOWN'
  END AS region_code,
  s.product,
  s.qty,
  s.price,
  ROUND(s.qty * s.price, 2) AS total_value
FROM stg_sales s
WHERE
  s.qty   > 0
  AND s.price > 0
  AND s.order_date IS NOT NULL;

DROP VIEW IF EXISTS vw_region_kpis;
CREATE VIEW vw_region_kpis AS
SELECT
  region_code,
  SUM(total_value)              AS revenue,
  ROUND(AVG(total_value), 2)    AS avg_order_value,
  COUNT(*)                      AS total_orders
FROM int_sales
GROUP BY region_code;

SELECT
    region_code,
    revenue,
    total_orders
FROM vw_region_kpis
ORDER BY revenue DESC;


DROP VIEW IF EXISTS vw_product_kpis;
CREATE VIEW vw_product_kpis AS
SELECT
  product,
  SUM(total_value) AS revenue
FROM int_sales
GROUP BY product;

SELECT product, revenue
FROM vw_product_kpis
ORDER BY revenue DESC
LIMIT 5;
