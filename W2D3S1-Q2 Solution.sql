-- ==========================================
-- Schema Evolution (Very Beginner Level)
-- Add Promo dimension without touching fact_sales
-- ==========================================

USE sales_warehouse;

DROP TABLE IF EXISTS fact_sales_promo_map;
DROP TABLE IF EXISTS dim_promo;

CREATE TABLE dim_promo (
  promo_key INT AUTO_INCREMENT PRIMARY KEY,
  promo_code VARCHAR(50) NOT NULL,
  promo_name VARCHAR(200) NOT NULL,
  discount_type VARCHAR(10) NOT NULL,
  discount_value DECIMAL(10,2) NOT NULL,
  start_date DATE NOT NULL,
  end_date DATE NOT NULL
);

CREATE TABLE fact_sales_promo_map (
  sales_id BIGINT NOT NULL,
  promo_key INT NOT NULL,
  promo_amount DECIMAL(12,2) NOT NULL,
  PRIMARY KEY (sales_id, promo_key),
  FOREIGN KEY (sales_id) REFERENCES fact_sales(sales_id),
  FOREIGN KEY (promo_key) REFERENCES dim_promo(promo_key)
);

INSERT INTO dim_promo (promo_code, promo_name, discount_type, discount_value, start_date, end_date) VALUES
('FLAT200','Flat 200 Off','AMT',200.00,'2025-10-01','2025-10-31'),
('PCT10','Ten Percent Off','PCT',10.00,'2025-10-01','2025-10-31');

INSERT INTO fact_sales_promo_map (sales_id, promo_key, promo_amount)
SELECT f.sales_id, p.promo_key, 200.00
FROM fact_sales f
JOIN dim_promo p ON p.promo_code = 'FLAT200'
WHERE f.sale_date BETWEEN '2025-10-01' AND '2025-10-31'
  AND f.quantity >= 2;

SELECT COUNT(*) AS promo_rows FROM dim_promo;
SELECT COUNT(*) AS mapped_rows FROM fact_sales_promo_map;
SELECT * FROM fact_sales_promo_map ORDER BY sales_id, promo_key;
