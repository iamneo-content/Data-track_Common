-- Active: 1759819378794@@127.0.0.1@3306@retail_database

CREATE DATABASE IF NOT EXISTS retail_database;
USE retail_database;

DROP VIEW IF EXISTS vw_mart_marketing;
DROP VIEW IF EXISTS vw_mart_finance;
DROP TABLE IF EXISTS fact_sales;
DROP TABLE IF EXISTS dim_date;
DROP TABLE IF EXISTS dim_product;
DROP TABLE IF EXISTS dim_customer;

CREATE TABLE dim_date (
  date_id INT PRIMARY KEY,
  full_date DATE,
  year INT,
  month_name VARCHAR(20)
);

CREATE TABLE dim_product (
  product_id INT PRIMARY KEY,
  product_name VARCHAR(50),
  category VARCHAR(50),
  cost DECIMAL(10,2)
);

CREATE TABLE dim_customer (
  customer_id INT PRIMARY KEY,
  customer_name VARCHAR(50),
  region VARCHAR(50)
);

CREATE TABLE fact_sales (
  sales_id INT AUTO_INCREMENT PRIMARY KEY,
  date_id INT,
  product_id INT,
  customer_id INT,
  qty INT,
  net_amount DECIMAL(10,2),
  FOREIGN KEY (date_id) REFERENCES dim_date(date_id),
  FOREIGN KEY (product_id) REFERENCES dim_product(product_id),
  FOREIGN KEY (customer_id) REFERENCES dim_customer(customer_id)
);

-- Marketing Mart: Region & Category performance
CREATE OR REPLACE VIEW vw_mart_marketing AS
SELECT 
  dp.category,
  dc.region,
  SUM(fs.net_amount) AS total_sales
FROM fact_sales fs
JOIN dim_product dp ON fs.product_id = dp.product_id
JOIN dim_customer dc ON fs.customer_id = dc.customer_id
GROUP BY dp.category, dc.region;

-- Finance Mart: Monthly Profitability
CREATE OR REPLACE VIEW vw_mart_finance AS
SELECT 
  dd.month_name,
  SUM(fs.net_amount) AS total_revenue,
  SUM(fs.qty * dp.cost) AS total_cost,
  (SUM(fs.net_amount) - SUM(fs.qty * dp.cost)) AS gross_margin
FROM fact_sales fs
JOIN dim_product dp ON fs.product_id = dp.product_id
JOIN dim_date dd ON fs.date_id = dd.date_id
GROUP BY dd.month_name;

SHOW TABLES;
DESC fact_sales;
DESC dim_product;
DESC dim_customer;
DESC dim_date;

SELECT * FROM vw_mart_marketing LIMIT 10;
SELECT * FROM vw_mart_finance LIMIT 10;

SELECT * FROM vw_mart_finance ORDER BY month_name;

SELECT region, SUM(total_sales) AS total_sales
FROM vw_mart_marketing
GROUP BY region
ORDER BY total_sales DESC;

