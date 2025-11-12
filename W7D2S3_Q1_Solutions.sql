-- =====================================================================
-- PRACTICE QUESTION: RETAIL ANALYTICS WAREHOUSE BUILD
-- =====================================================================
-- Scenario:
-- A retail company wants to analyze monthly revenue trends
-- and identify top-performing products by region.
--
-- Tasks:
--  Create a Snowflake schema with 4 dimension tables and 1 fact table.
--  Load data from S3 (CSV files).
--  Query total revenue by region and month.
--
-- S3 Source : s3://demo-616700456562/retail_warehouse/
-- IAM Role  : arn:aws:iam::616700456562:role/service-role/AmazonRedshift-CommandsAccessRole-20251112T184408
-- =====================================================================


-- =====================================================================
-- STEP 1: Drop existing tables if re-run
-- =====================================================================
DROP TABLE IF EXISTS fact_sales;
DROP TABLE IF EXISTS dim_customer;
DROP TABLE IF EXISTS dim_city;
DROP TABLE IF EXISTS dim_product;
DROP TABLE IF EXISTS dim_date;


-- =====================================================================
-- STEP 2: Create dimension tables
-- =====================================================================

CREATE TABLE dim_city (
    city_id INT PRIMARY KEY,
    city_name VARCHAR(100),
    region VARCHAR(50)
);

CREATE TABLE dim_customer (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100),
    city_id INT REFERENCES dim_city(city_id)
);

CREATE TABLE dim_product (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100),
    category VARCHAR(50)
);

CREATE TABLE dim_date (
    date_id INT PRIMARY KEY,
    date DATE,
    month VARCHAR(20),
    year INT
);


-- =====================================================================
-- STEP 3: Create fact table
-- =====================================================================

CREATE TABLE fact_sales (
    sale_id INT PRIMARY KEY,
    customer_id INT REFERENCES dim_customer(customer_id),
    product_id INT REFERENCES dim_product(product_id),
    date_id INT REFERENCES dim_date(date_id),
    quantity INT,
    total_amount NUMERIC(12,2)
);


-- =====================================================================
-- STEP 4: Load data from S3 (Retail Warehouse Folder)
-- =====================================================================

COPY dim_city
FROM 's3://demo-616700456562/retail_warehouse/dim_city.csv'
IAM_ROLE 'arn:aws:iam::616700456562:role/service-role/AmazonRedshift-CommandsAccessRole-20251112T184408'
CSV
IGNOREHEADER 1
REGION 'us-east-2';

COPY dim_customer
FROM 's3://demo-616700456562/retail_warehouse/dim_customer.csv'
IAM_ROLE 'arn:aws:iam::616700456562:role/service-role/AmazonRedshift-CommandsAccessRole-20251112T184408'
CSV
IGNOREHEADER 1
REGION 'us-east-2';

COPY dim_product
FROM 's3://demo-616700456562/retail_warehouse/dim_product.csv'
IAM_ROLE 'arn:aws:iam::616700456562:role/service-role/AmazonRedshift-CommandsAccessRole-20251112T184408'
CSV
IGNOREHEADER 1
REGION 'us-east-2';

COPY dim_date
FROM 's3://demo-616700456562/retail_warehouse/dim_date.csv'
IAM_ROLE 'arn:aws:iam::616700456562:role/service-role/AmazonRedshift-CommandsAccessRole-20251112T184408'
CSV
IGNOREHEADER 1
DATEFORMAT 'auto'
REGION 'us-east-2';

COPY fact_sales
FROM 's3://demo-616700456562/retail_warehouse/fact_sales.csv'
IAM_ROLE 'arn:aws:iam::616700456562:role/service-role/AmazonRedshift-CommandsAccessRole-20251112T184408'
CSV
IGNOREHEADER 1
REGION 'us-east-2';


-- =====================================================================
-- STEP 5: Validate load counts
-- =====================================================================

SELECT 'dim_city' AS table_name, COUNT(*) AS row_count FROM dim_city
UNION ALL
SELECT 'dim_customer', COUNT(*) FROM dim_customer
UNION ALL
SELECT 'dim_product', COUNT(*) FROM dim_product
UNION ALL
SELECT 'dim_date', COUNT(*) FROM dim_date
UNION ALL
SELECT 'fact_sales', COUNT(*) FROM fact_sales;


-- =====================================================================
-- STEP 6: Query – Total revenue by region and month
-- =====================================================================
SELECT
    c.region,
    d.month,
    d.year,
    SUM(f.total_amount) AS total_revenue
FROM fact_sales f
JOIN dim_customer cu ON f.customer_id = cu.customer_id
JOIN dim_city c ON cu.city_id = c.city_id
JOIN dim_date d ON f.date_id = d.date_id
GROUP BY c.region, d.year, d.month
ORDER BY d.year, d.month, total_revenue DESC
LIMIT 5;


