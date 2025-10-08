-- Active: 1759911087247@@127.0.0.1@3306@customer_insights

USE customer_insights;

TRUNCATE TABLE feedback_clean;

INSERT INTO feedback_clean (feedback_id, customer_id, product_id, rating, comment, feedback_date)
SELECT
    feedback_id,
    customer_id,
    product_id,
    rating,
    IFNULL(comment, 'No Comment') AS comment,
    feedback_date
FROM raw_feedback;

SELECT *
FROM feedback_clean
WHERE comment = 'No Comment'
ORDER BY feedback_id;

SELECT * FROM feedback_clean LIMIT 10;
