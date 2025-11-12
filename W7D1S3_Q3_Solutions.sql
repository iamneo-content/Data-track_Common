-- =====================================================================
-- PRACTICE QUESTION:
-- RUNNING TOTAL AND MOVING AVERAGE USING WINDOW FUNCTIONS
-- =====================================================================
-- Objective:
--  Compute daily total revenue per city.
--  Calculate a 7-day rolling average using window frame.
--  Output → order_date, city, total_sales, moving_avg_7d
-- =====================================================================

-- =====================================================================
-- STEP 1: Drop and recreate table
-- =====================================================================
DROP TABLE IF EXISTS daily_revenue;

CREATE TABLE daily_revenue (
    order_id INT,
    city VARCHAR(50),
    order_date DATE,
    amount NUMERIC(10,2)
);

-- =====================================================================
-- STEP 2: Insert 50 realistic rows (across 3 cities, 50 days)
-- =====================================================================
INSERT INTO daily_revenue VALUES
(1, 'Delhi', '2024-01-01', 520.00),
(2, 'Mumbai', '2024-01-01', 610.00),
(3, 'Bangalore', '2024-01-01', 700.00),
(4, 'Delhi', '2024-01-02', 560.00),
(5, 'Mumbai', '2024-01-02', 640.00),
(6, 'Bangalore', '2024-01-02', 710.00),
(7, 'Delhi', '2024-01-03', 600.00),
(8, 'Mumbai', '2024-01-03', 590.00),
(9, 'Bangalore', '2024-01-03', 740.00),
(10, 'Delhi', '2024-01-04', 620.00),
(11, 'Mumbai', '2024-01-04', 630.00),
(12, 'Bangalore', '2024-01-04', 720.00),
(13, 'Delhi', '2024-01-05', 580.00),
(14, 'Mumbai', '2024-01-05', 670.00),
(15, 'Bangalore', '2024-01-05', 760.00),
(16, 'Delhi', '2024-01-06', 650.00),
(17, 'Mumbai', '2024-01-06', 720.00),
(18, 'Bangalore', '2024-01-06', 800.00),
(19, 'Delhi', '2024-01-07', 700.00),
(20, 'Mumbai', '2024-01-07', 780.00),
(21, 'Bangalore', '2024-01-07', 850.00),
(22, 'Delhi', '2024-01-08', 670.00),
(23, 'Mumbai', '2024-01-08', 810.00),
(24, 'Bangalore', '2024-01-08', 830.00),
(25, 'Delhi', '2024-01-09', 710.00),
(26, 'Mumbai', '2024-01-09', 840.00),
(27, 'Bangalore', '2024-01-09', 900.00),
(28, 'Delhi', '2024-01-10', 750.00),
(29, 'Mumbai', '2024-01-10', 880.00),
(30, 'Bangalore', '2024-01-10', 920.00),
(31, 'Delhi', '2024-01-11', 780.00),
(32, 'Mumbai', '2024-01-11', 850.00),
(33, 'Bangalore', '2024-01-11', 950.00),
(34, 'Delhi', '2024-01-12', 810.00),
(35, 'Mumbai', '2024-01-12', 900.00),
(36, 'Bangalore', '2024-01-12', 970.00),
(37, 'Delhi', '2024-01-13', 790.00),
(38, 'Mumbai', '2024-01-13', 880.00),
(39, 'Bangalore', '2024-01-13', 960.00),
(40, 'Delhi', '2024-01-14', 760.00),
(41, 'Mumbai', '2024-01-14', 870.00),
(42, 'Bangalore', '2024-01-14', 940.00),
(43, 'Delhi', '2024-01-15', 800.00),
(44, 'Mumbai', '2024-01-15', 890.00),
(45, 'Bangalore', '2024-01-15', 970.00),
(46, 'Delhi', '2024-01-16', 820.00),
(47, 'Mumbai', '2024-01-16', 920.00),
(48, 'Bangalore', '2024-01-16', 990.00),
(49, 'Delhi', '2024-01-17', 850.00),
(50, 'Mumbai', '2024-01-17', 950.00);

-- =====================================================================
-- STEP 3: Aggregate & compute moving average
-- =====================================================================

WITH daily_totals AS (
    SELECT
        order_date,
        city,
        SUM(amount) AS total_sales
    FROM daily_revenue
    GROUP BY order_date, city
),
moving_calc AS (
    SELECT
        city,
        order_date,
        total_sales,
        ROUND(
            AVG(total_sales) OVER (
                PARTITION BY city
                ORDER BY order_date
                ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
            ), 2
        ) AS moving_avg_7d
    FROM daily_totals
)
SELECT *
FROM moving_calc
ORDER BY city, order_date;

-- =====================================================================
-- EXPECTED OUTPUT:
-- order_date | city | total_sales | moving_avg_7d
-- =====================================================================
