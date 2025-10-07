--complete your solution here
USE transactions;
DELETE FROM stg_transactions
WHERE amount < 0;

-- Step 2: Standardize status to uppercase
UPDATE stg_transactions
SET status = UPPER(TRIM(status))
WHERE status IS NOT NULL;

-- Step 3: Add derived month column
ALTER TABLE stg_transactions
ADD COLUMN txn_month INT;

UPDATE stg_transactions
SET txn_month = MONTH(txn_date);

-- Step 4: Validate cleaned dataset
SELECT txn_id, txn_date, txn_month, amount, status
FROM stg_transactions
ORDER BY txn_date, txn_id
LIMIT 20;
