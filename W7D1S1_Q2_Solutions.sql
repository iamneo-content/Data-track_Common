=====================================================================
—- FACT TABLE DESIGN — FINANCE TRANSACTIONS
-- =====================================================================
-- Objective:
--   Design a transaction-level fact table referencing card, merchant,
--   and date dimensions. Demonstrate use of surrogate keys, measures,
--   and foreign key constraints.
-- =====================================================================

-- =====================================================================
-- STEP 0: Clean up existing objects (safe re-run)
-- =====================================================================
DROP TABLE IF EXISTS fact_transactions;
DROP TABLE IF EXISTS dim_card;
DROP TABLE IF EXISTS dim_merchant;
DROP TABLE IF EXISTS dim_date;

-- =====================================================================
-- STEP 1: Create Dimension Tables
-- =====================================================================

CREATE TABLE dim_card (
    card_id INT PRIMARY KEY,
    card_number VARCHAR(20),
    card_type VARCHAR(20),
    bank_name VARCHAR(50),
    cardholder_name VARCHAR(100)
);

CREATE TABLE dim_merchant (
    merchant_id INT PRIMARY KEY,
    merchant_name VARCHAR(100),
    merchant_category VARCHAR(50),
    country VARCHAR(50)
);

CREATE TABLE dim_date (
    date_id INT PRIMARY KEY,
    full_date DATE,
    day SMALLINT,
    month SMALLINT,
    month_name VARCHAR(20),
    year SMALLINT,
    weekday VARCHAR(15)
);

-- =====================================================================
-- STEP 2: Create Fact Table
-- =====================================================================

CREATE TABLE fact_transactions (
    transaction_id BIGINT PRIMARY KEY,
    card_id INT REFERENCES dim_card(card_id),
    merchant_id INT REFERENCES dim_merchant(merchant_id),
    date_id INT REFERENCES dim_date(date_id),
    amount DECIMAL(10,2),
    fee DECIMAL(8,2),
    is_fraud SMALLINT
);

-- =====================================================================
-- STEP 3: Load Data from S3 (Update bucket & IAM role if needed)
-- =====================================================================

COPY dim_card
FROM 's3://demo-616700456562/q3_finance_transactions/dim_card.csv'
IAM_ROLE 'arn:aws:iam::616700456562:role/service-role/AmazonRedshift-CommandsAccessRole-20251112T095845'
CSV
IGNOREHEADER 1
REGION 'us-east-2';

COPY dim_merchant
FROM 's3://demo-616700456562/q3_finance_transactions/dim_merchant.csv'
IAM_ROLE 'arn:aws:iam::616700456562:role/service-role/AmazonRedshift-CommandsAccessRole-20251112T095845'
CSV
IGNOREHEADER 1
REGION 'us-east-2';

COPY dim_date
FROM 's3://demo-616700456562/q3_finance_transactions/dim_date.csv'
IAM_ROLE 'arn:aws:iam::616700456562:role/service-role/AmazonRedshift-CommandsAccessRole-20251112T095845'
CSV
IGNOREHEADER 1
REGION 'us-east-2';

COPY fact_transactions
FROM 's3://demo-616700456562/q3_finance_transactions/fact_transactions.csv'
IAM_ROLE 'arn:aws:iam::616700456562:role/service-role/AmazonRedshift-CommandsAccessRole-20251112T095845'
CSV
IGNOREHEADER 1
REGION 'us-east-2';

-- =====================================================================
-- STEP 4: Verify Table Creation
-- =====================================================================

-- List all tables in public schema
SELECT tablename 
FROM pg_table_def
WHERE schemaname = 'public'
GROUP BY tablename
ORDER BY tablename;

-- Check Fact Table DDL
SELECT "column", type, encoding, distkey, sortkey, "notnull"
FROM pg_table_def
WHERE tablename = 'fact_transactions';

-- =====================================================================
-- STEP 5: Validate Data Load
-- =====================================================================
SELECT 
    (SELECT COUNT(*) FROM dim_card) AS card_count,
    (SELECT COUNT(*) FROM dim_merchant) AS merchant_count,
    (SELECT COUNT(*) FROM dim_date) AS date_count,
    (SELECT COUNT(*) FROM fact_transactions) AS transaction_count;

-- =====================================================================
-- STEP 6: Analytical Query
-- Top 5 merchants by total transaction amount
-- =====================================================================

SELECT 
    m.merchant_name,
    ROUND(SUM(f.amount), 2) AS total_transaction_amount
FROM fact_transactions f
JOIN dim_merchant m ON f.merchant_id = m.merchant_id
GROUP BY m.merchant_name
ORDER BY total_transaction_amount DESC
LIMIT 5;

-- =====================================================================
-- STEP 7: Fraud Analysis (optional insight)
-- =====================================================================

SELECT 
    m.merchant_name,
    COUNT(*) AS total_transactions,
    SUM(CASE WHEN f.is_fraud = 1 THEN 1 ELSE 0 END) AS fraud_count,
    ROUND(100.0 * SUM(CASE WHEN f.is_fraud = 1 THEN 1 ELSE 0 END) / COUNT(*), 2) AS fraud_percent
FROM fact_transactions f
JOIN dim_merchant m ON f.merchant_id = m.merchant_id
GROUP BY m.merchant_name
ORDER BY fraud_percent DESC
LIMIT 5;

-- =====================================================================
-- END OF SCRIPT
-- =====================================================================
