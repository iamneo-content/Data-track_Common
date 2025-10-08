USE library_circulation_db;

UPDATE loan_staging
SET category = 'Unknown'
WHERE category IS NULL OR TRIM(category) = '';

UPDATE loan_staging
SET category = UPPER(TRIM(category));

UPDATE loan_staging
SET member_name = TRIM(member_name),
    book_title  = TRIM(book_title);

UPDATE loan_staging
SET late_fee = 0
WHERE late_fee IS NULL OR late_fee < 0;

UPDATE loan_staging
SET return_date = DATE_ADD(loan_date, INTERVAL 14 DAY)
WHERE return_date IS NULL OR return_date < loan_date;

SELECT *
FROM loan_staging
ORDER BY loan_id;
