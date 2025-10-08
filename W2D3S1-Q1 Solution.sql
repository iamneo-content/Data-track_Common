-- Active: 1759899987701@@127.0.0.1@3306@bookstore_database
-- =============================================================
-- Online Bookstore - Snowflake Schema (Solution SQL)
-- =============================================================

CREATE DATABASE IF NOT EXISTS bookstore_database;
USE bookstore_database;

-- =============================================================
-- DIMENSION TABLES
-- =============================================================

-- ---------------------------
-- dim_author
-- ---------------------------
CREATE TABLE dim_author (
    author_key INT PRIMARY KEY,
    author_code VARCHAR(10),
    author_name VARCHAR(100),
    birth_date DATE,
    country VARCHAR(50)
);

-- ---------------------------
-- dim_publisher
-- ---------------------------
CREATE TABLE dim_publisher (
    publisher_key INT PRIMARY KEY,
    publisher_code VARCHAR(10),
    publisher_name VARCHAR(100),
    country VARCHAR(50)
);

-- ---------------------------
-- dim_book
-- ---------------------------
CREATE TABLE dim_book (
    book_key INT PRIMARY KEY,
    isbn VARCHAR(20),
    title VARCHAR(150),
    genre VARCHAR(50),
    author_key INT,
    publisher_key INT,
    publish_year INT,
    list_price DECIMAL(10,2),
    FOREIGN KEY (author_key) REFERENCES dim_author(author_key),
    FOREIGN KEY (publisher_key) REFERENCES dim_publisher(publisher_key)
);

-- ---------------------------
-- dim_customer
-- ---------------------------
CREATE TABLE dim_customer (
    customer_key INT PRIMARY KEY,
    customer_code VARCHAR(10),
    full_name VARCHAR(100),
    email VARCHAR(100),
    city VARCHAR(50),
    state VARCHAR(50),
    country VARCHAR(50),
    signup_date DATE
);

-- ---------------------------
-- dim_date
-- ---------------------------
CREATE TABLE dim_date (
    date_key INT PRIMARY KEY,
    calendar_date DATE,
    year INT,
    month INT,
    month_name VARCHAR(20),
    day INT
);

CREATE TABLE fact_sales (
    sales_key INT PRIMARY KEY,
    book_key INT,
    customer_key INT,
    date_key INT,
    quantity INT,
    unit_price DECIMAL(10,2),
    total_amount DECIMAL(10,2),
    FOREIGN KEY (book_key) REFERENCES dim_book(book_key),
    FOREIGN KEY (customer_key) REFERENCES dim_customer(customer_key),
    FOREIGN KEY (date_key) REFERENCES dim_date(date_key)
);

-- =============================================================
-- VALIDATION CHECKS
-- =============================================================

-- Verify record counts
SELECT 'dim_author' AS table_name, COUNT(*) AS total_rows FROM dim_author
UNION ALL SELECT 'dim_publisher', COUNT(*) FROM dim_publisher
UNION ALL SELECT 'dim_book', COUNT(*) FROM dim_book
UNION ALL SELECT 'dim_customer', COUNT(*) FROM dim_customer
UNION ALL SELECT 'dim_date', COUNT(*) FROM dim_date
UNION ALL SELECT 'fact_sales', COUNT(*) FROM fact_sales;

-- Check for orphan foreign keys
SELECT fs.sales_key
FROM fact_sales fs
LEFT JOIN dim_book b ON fs.book_key = b.book_key
LEFT JOIN dim_customer c ON fs.customer_key = c.customer_key
LEFT JOIN dim_date d ON fs.date_key = d.date_key
WHERE b.book_key IS NULL OR c.customer_key IS NULL OR d.date_key IS NULL;

-- =============================================================
-- ANALYTICAL QUERIES
-- =============================================================

-- Q1: Top 3 authors by total revenue
SELECT
    a.author_name,
    ROUND(SUM(fs.total_amount), 2) AS total_revenue
FROM fact_sales fs
JOIN dim_book b ON fs.book_key = b.book_key
JOIN dim_author a ON b.author_key = a.author_key
GROUP BY a.author_name
ORDER BY total_revenue DESC
LIMIT 3;

-- Q2: Revenue per publisher per month
SELECT
    p.publisher_name,
    d.year,
    d.month_name,
    ROUND(SUM(fs.total_amount), 2) AS monthly_revenue
FROM fact_sales fs
JOIN dim_book b ON fs.book_key = b.book_key
JOIN dim_publisher p ON b.publisher_key = p.publisher_key
JOIN dim_date d ON fs.date_key = d.date_key
GROUP BY p.publisher_name, d.year, d.month_name
ORDER BY p.publisher_name, d.year, d.month_name;

-- Q3: Customer count by state and genre
SELECT
    c.state,
    b.genre,
    COUNT(DISTINCT c.customer_key) AS customer_count
FROM fact_sales fs
JOIN dim_customer c ON fs.customer_key = c.customer_key
JOIN dim_book b ON fs.book_key = b.book_key
GROUP BY c.state, b.genre
ORDER BY c.state, b.genre;

