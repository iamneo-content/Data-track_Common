
USE procurement_analytics;

DROP TABLE IF EXISTS city_map;
CREATE TABLE city_map (
    city_variant   VARCHAR(60) PRIMARY KEY,
    standard_city  VARCHAR(60) NOT NULL`
);

INSERT INTO city_map (city_variant, standard_city) VALUES
('mumbai','Mumbai'), ('bombay','Mumbai'),
('pune','Pune'),
('delhi','Delhi'), ('new delhi','Delhi'),
('chennai','Chennai'),
('bengaluru','Bengaluru'), ('bangalore','Bengaluru'),
('kolkata','Kolkata'), ('calcutta','Kolkata'),
('hyderabad','Hyderabad'),
('ahmedabad','Ahmedabad');

DROP TABLE IF EXISTS suppliers_stage;
CREATE TABLE suppliers_stage AS
SELECT
  supplier_id,
  TRIM(company_name)                  AS company_name,
  LOWER(TRIM(contact_email))          AS contact_email,
  TRIM(city)                          AS city,
  TRIM(contact_age)                   AS contact_age,
  onboarding_date
FROM raw_suppliers;

UPDATE suppliers_stage s
LEFT JOIN city_map m
  ON LOWER(TRIM(s.city)) = m.city_variant
SET s.city = COALESCE(m.standard_city, s.city);

UPDATE suppliers_stage
SET contact_age = NULL
WHERE contact_age IS NULL
   OR contact_age = ''
   OR contact_age NOT REGEXP '^[0-9]+$'
   OR CAST(contact_age AS UNSIGNED) < 18
   OR CAST(contact_age AS UNSIGNED) > 90;

DROP TABLE IF EXISTS suppliers_clean;
CREATE TABLE suppliers_clean AS
SELECT
  MIN(supplier_id) AS supplier_id,         
  company_name,
  contact_email,
  city,
  CAST(contact_age AS UNSIGNED) AS contact_age,
  MIN(onboarding_date) AS onboarding_date
FROM suppliers_stage
GROUP BY company_name, contact_email, city, contact_age;

SELECT * FROM suppliers_clean ORDER BY company_name, contact_email, onboarding_date;
