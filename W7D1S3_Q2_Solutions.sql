-- =====================================================================
-- PRACTICE QUESTION:
-- CHAIN MULTIPLE CTEs – REGIONAL SALES ANALYSIS
-- =====================================================================
-- Objective:
--  First CTE → Calculate total sales per region.
--  Second CTE → Calculate each region’s % contribution to total.
--  Output → region, total_sales, pct_of_total
-- =====================================================================

-- =====================================================================
-- STEP 1: Drop and recreate base table
-- =====================================================================
DROP TABLE IF EXISTS sales_data;

CREATE TABLE sales_data (
    sale_id INT,
    region VARCHAR(50),
    product_category VARCHAR(50),
    quantity INT,
    price_per_unit NUMERIC(10,2),
    sale_date DATE
);

-- =====================================================================
-- STEP 2: Insert 50 realistic sales records
-- =====================================================================
INSERT INTO sales_data VALUES
(1, 'North', 'Electronics', 3, 1200.00, '2024-01-02'),
(2, 'South', 'Fashion', 5, 450.00, '2024-01-03'),
(3, 'East', 'Grocery', 20, 80.00, '2024-01-04'),
(4, 'West', 'Books', 10, 150.00, '2024-01-04'),
(5, 'North', 'Electronics', 2, 1800.00, '2024-01-05'),
(6, 'South', 'Home', 1, 2400.00, '2024-01-05'),
(7, 'East', 'Grocery', 15, 70.00, '2024-01-06'),
(8, 'West', 'Fashion', 4, 550.00, '2024-01-07'),
(9, 'North', 'Books', 5, 300.00, '2024-01-08'),
(10, 'South', 'Electronics', 1, 2000.00, '2024-01-08'),
(11, 'East', 'Fashion', 3, 650.00, '2024-01-09'),
(12, 'West', 'Home', 2, 1800.00, '2024-01-09'),
(13, 'North', 'Grocery', 10, 90.00, '2024-01-10'),
(14, 'South', 'Books', 7, 250.00, '2024-01-10'),
(15, 'East', 'Electronics', 2, 1500.00, '2024-01-11'),
(16, 'West', 'Home', 3, 1750.00, '2024-01-11'),
(17, 'North', 'Fashion', 6, 600.00, '2024-01-12'),
(18, 'South', 'Grocery', 8, 100.00, '2024-01-13'),
(19, 'East', 'Home', 1, 2200.00, '2024-01-13'),
(20, 'West', 'Electronics', 3, 1300.00, '2024-01-14'),
(21, 'North', 'Home', 1, 2500.00, '2024-01-15'),
(22, 'South', 'Electronics', 2, 1500.00, '2024-01-15'),
(23, 'East', 'Books', 6, 200.00, '2024-01-16'),
(24, 'West', 'Grocery', 15, 90.00, '2024-01-17'),
(25, 'North', 'Fashion', 4, 700.00, '2024-01-18'),
(26, 'South', 'Books', 9, 180.00, '2024-01-19'),
(27, 'East', 'Electronics', 3, 1700.00, '2024-01-20'),
(28, 'West', 'Fashion', 7, 480.00, '2024-01-21'),
(29, 'North', 'Home', 2, 2600.00, '2024-01-22'),
(30, 'South', 'Grocery', 12, 85.00, '2024-01-23'),
(31, 'East', 'Books', 8, 220.00, '2024-01-24'),
(32, 'West', 'Electronics', 4, 1200.00, '2024-01-25'),
(33, 'North', 'Electronics', 1, 2100.00, '2024-01-26'),
(34, 'South', 'Fashion', 5, 550.00, '2024-01-27'),
(35, 'East', 'Home', 2, 2000.00, '2024-01-27'),
(36, 'West', 'Books', 10, 190.00, '2024-01-28'),
(37, 'North', 'Books', 6, 250.00, '2024-01-29'),
(38, 'South', 'Electronics', 3, 1600.00, '2024-01-30'),
(39, 'East', 'Fashion', 5, 500.00, '2024-01-30'),
(40, 'West', 'Grocery', 10, 95.00, '2024-02-01'),
(41, 'North', 'Fashion', 3, 550.00, '2024-02-02'),
(42, 'South', 'Books', 4, 200.00, '2024-02-03'),
(43, 'East', 'Grocery', 20, 75.00, '2024-02-03'),
(44, 'West', 'Home', 1, 2700.00, '2024-02-04'),
(45, 'North', 'Home', 2, 2300.00, '2024-02-05'),
(46, 'South', 'Electronics', 1, 2200.00, '2024-02-06'),
(47, 'East', 'Fashion', 3, 600.00, '2024-02-06'),
(48, 'West', 'Electronics', 2, 1400.00, '2024-02-07'),
(49, 'North', 'Grocery', 15, 85.00, '2024-02-07'),
(50, 'South', 'Home', 2, 2000.00, '2024-02-08');

-- =====================================================================
-- STEP 3: Chain two CTEs
-- =====================================================================

WITH region_sales AS (
    SELECT
        region,
        SUM(quantity * price_per_unit) AS total_sales
    FROM sales_data
    GROUP BY region
),
region_pct AS (
    SELECT
        region,
        total_sales,
        ROUND( (total_sales * 100.0) / SUM(total_sales) OVER(), 2) AS total_percentage
    FROM region_sales
)
SELECT * 
FROM region_pct
ORDER BY total_sales DESC;

