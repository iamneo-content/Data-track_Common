-- =====================================================================
-- PRACTICE QUESTION: DIGITAL PAYMENTS TRANSACTION INSIGHTS
-- =====================================================================
-- Scenario:
-- A national payments company must analyze monthly performance
-- across regions to track revenue, refunds, and fraud trends.
-- =====================================================================
-- S3 Path: s3://lab-rawzone-digitalpay/transactions/transactions_raw.csv
-- IAM Role: arn:aws:iam::616700456562:role/service-role/AmazonRedshift-CommandsAccessRole-20251112T184408
-- =====================================================================

-- =====================================================================
-- STEP 1: Drop existing tables if re-run
-- =====================================================================
DROP TABLE IF EXISTS stg_transactions;
DROP TABLE IF EXISTS fact_transactions;
DROP TABLE IF EXISTS agg_monthly_metrics;

-- =====================================================================
-- STEP 2: Create staging table (raw load)
-- =====================================================================
CREATE TABLE stg_transactions (
    txn_id INT,
    merchant_id INT,
    txn_date DATE,
    txn_type VARCHAR(20),
    region VARCHAR(50),
    amount NUMERIC(12,2),
    is_fraud BOOLEAN
);

-- =====================================================================
-- STEP 3: COPY data from S3 into staging table
-- =====================================================================
COPY stg_transactions
FROM 's3://demo-616700456562/transactions/transactions_raw.csv'
IAM_ROLE 'arn:aws:iam::616700456562:role/service-role/AmazonRedshift-CommandsAccessRole-20251112T184408'
CSV
IGNOREHEADER 1
DATEFORMAT 'auto'
REGION 'us-east-2';

-- Verify raw load
SELECT COUNT(*) AS total_raw_records FROM stg_transactions;
SELECT * FROM stg_transactions LIMIT 5;

-- =====================================================================
-- STEP 4: Create cleaned fact table
-- =====================================================================
CREATE TABLE fact_transactions (
    txn_id INT PRIMARY KEY,
    merchant_id INT,
    txn_date DATE,
    txn_type VARCHAR(20),
    region VARCHAR(50),
    amount NUMERIC(12,2),
    is_fraud BOOLEAN,
    created_at TIMESTAMP DEFAULT GETDATE(),
    updated_at TIMESTAMP
);

-- =====================================================================
-- STEP 5: Data cleaning and insert
--  - Remove duplicates
--  - Exclude zero or negative amounts
--  - Replace NULL region with 'Unknown'
-- =====================================================================
INSERT INTO fact_transactions (
    txn_id, merchant_id, txn_date, txn_type, region, amount, is_fraud, updated_at
)
SELECT DISTINCT
    txn_id,
    merchant_id,
    txn_date,
    txn_type,
    COALESCE(region, 'Unknown') AS region,
    amount,
    is_fraud,
    CAST(NULL AS TIMESTAMP) AS updated_at
FROM stg_transactions
WHERE amount > 0
  AND txn_date <= GETDATE();

-- Validate clean load
SELECT
    (SELECT COUNT(*) FROM stg_transactions) AS before_cleaning,
    (SELECT COUNT(*) FROM fact_transactions) AS after_cleaning;

SELECT * FROM fact_transactions LIMIT 5;

-- =====================================================================
-- STEP 6: Create aggregation table for KPIs
-- =====================================================================
CREATE TABLE agg_monthly_metrics (
    month VARCHAR(15),
    region VARCHAR(50),
    total_txns INT,
    total_amount NUMERIC(14,2),
    avg_txn_amount NUMERIC(12,2),
    refund_amount NUMERIC(14,2),
    fraud_txns INT,
    fraud_rate_pct NUMERIC(6,2),
    created_at TIMESTAMP DEFAULT GETDATE()
);

-- =====================================================================
-- STEP 7: Populate aggregation table
-- =====================================================================
INSERT INTO agg_monthly_metrics (
    month, region, total_txns, total_amount,
    avg_txn_amount, refund_amount, fraud_txns, fraud_rate_pct
)
SELECT
    TO_CHAR(txn_date, 'YYYY-MM') AS month,
    region,
    COUNT(*) AS total_txns,
    SUM(amount) AS total_amount,
    ROUND(AVG(amount), 2) AS avg_txn_amount,
    SUM(CASE WHEN txn_type = 'REFUND' THEN amount ELSE 0 END) AS refund_amount,
    SUM(CASE WHEN is_fraud THEN 1 ELSE 0 END) AS fraud_txns,
    ROUND((SUM(CASE WHEN is_fraud THEN 1 ELSE 0 END) * 100.0) / COUNT(*), 2) AS fraud_rate_pct
FROM fact_transactions
GROUP BY 1, 2
ORDER BY 1, 2;

-- =====================================================================
-- STEP 8: Validate results
-- =====================================================================
SELECT COUNT(*) AS total_months FROM agg_monthly_metrics;
SELECT * FROM agg_monthly_metrics ORDER BY month, region LIMIT 10;

-- =====================================================================
-- STEP 9: Optional — View DDLs
-- =====================================================================
-- SHOW CREATE TABLE fact_transactions;
-- SHOW CREATE TABLE agg_monthly_metrics;

