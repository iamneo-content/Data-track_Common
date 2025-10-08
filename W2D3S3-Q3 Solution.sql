
USE enterprise_sales_dw;

START TRANSACTION;

TRUNCATE TABLE fact_customer_orders;

INSERT INTO fact_customer_orders (
    order_id,
    customer_id,
    order_date,
    order_amount_inr,
    order_status,
    last_modified_ts
)
SELECT
    s.order_id,
    s.customer_id,
    s.order_date,
    s.order_amount_inr,
    s.order_status,
    s.last_modified_ts
FROM stg_customer_orders AS s
WHERE s.order_status = 'NEW';

SELECT 
    COUNT(*) AS loaded_row_count,
    MIN(order_date) AS earliest_order,
    MAX(order_date) AS latest_order
FROM fact_customer_orders;

COMMIT;

SELECT * FROM fact_customer_orders;