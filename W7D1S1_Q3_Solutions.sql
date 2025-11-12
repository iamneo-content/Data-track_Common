-- =====================================================================
-- IMPLEMENT METADATA COLUMNS — HEALTHCARE PATIENTS (Snowflake Schema)
-- =====================================================================
-- Objective:
--   Create normalized dimension tables with metadata tracking columns.
--   Demonstrate audit trail behavior for INSERT and UPDATE actions.
-- =====================================================================

-- =====================================================================
-- STEP 0: Clean up existing objects (safe re-run)
-- =====================================================================
DROP TABLE IF EXISTS dim_patient;
DROP TABLE IF EXISTS dim_hospital;
DROP TABLE IF EXISTS dim_city;
DROP TABLE IF EXISTS dim_country;

-- =====================================================================
-- STEP 1: Create Tables (Snowflake Structure)
-- =====================================================================

-- Country Dimension
CREATE TABLE dim_country (
    country_id INT PRIMARY KEY,
    country_name VARCHAR(100),
    created_at TIMESTAMP DEFAULT GETDATE(),
    updated_at TIMESTAMP
);

-- City Dimension
CREATE TABLE dim_city (
    city_id INT PRIMARY KEY,
    city_name VARCHAR(100),
    country_id INT REFERENCES dim_country(country_id),
    created_at TIMESTAMP DEFAULT GETDATE(),
    updated_at TIMESTAMP
);

-- Hospital Dimension
CREATE TABLE dim_hospital (
    hospital_id INT PRIMARY KEY,
    hospital_name VARCHAR(150),
    city_id INT REFERENCES dim_city(city_id),
    bed_capacity INT,
    specialization VARCHAR(100),
    created_at TIMESTAMP DEFAULT GETDATE(),
    updated_at TIMESTAMP
);

-- Patient Dimension
CREATE TABLE dim_patient (
    patient_id INT PRIMARY KEY,
    patient_name VARCHAR(100),
    age SMALLINT,
    gender VARCHAR(10),
    hospital_id INT REFERENCES dim_hospital(hospital_id),
    admission_date DATE,
    discharge_date DATE,
    created_at TIMESTAMP DEFAULT GETDATE(),
    updated_at TIMESTAMP
);

-- =====================================================================
-- STEP 2: Load Data from S3
-- =====================================================================

COPY dim_country
FROM 's3://demo-616700456562/q4_healthcare_metadata/dim_country.csv'
IAM_ROLE 'arn:aws:iam::616700456562:role/service-role/AmazonRedshift-CommandsAccessRole-20251112T095845'
CSV
IGNOREHEADER 1
REGION 'us-east-2';

COPY dim_city
FROM 's3://demo-616700456562/q4_healthcare_metadata/dim_city.csv'
IAM_ROLE 'arn:aws:iam::616700456562:role/service-role/AmazonRedshift-CommandsAccessRole-20251112T095845'
CSV
IGNOREHEADER 1
REGION 'us-east-2';

COPY dim_hospital
FROM 's3://demo-616700456562/q4_healthcare_metadata/dim_hospital.csv'
IAM_ROLE 'arn:aws:iam::616700456562:role/service-role/AmazonRedshift-CommandsAccessRole-20251112T095845'
CSV
IGNOREHEADER 1
REGION 'us-east-2';

COPY dim_patient
FROM 's3://demo-616700456562/q4_healthcare_metadata/dim_patient.csv'
IAM_ROLE 'arn:aws:iam::616700456562:role/service-role/AmazonRedshift-CommandsAccessRole-20251112T095845'
CSV
IGNOREHEADER 1
REGION 'us-east-2';

-- =====================================================================
-- STEP 3: Verify Table Structures & Metadata Columns
-- =====================================================================

-- Verify dim_patient column defaults
SELECT column_name, column_default
FROM information_schema.columns
WHERE table_name = 'dim_patient'
ORDER BY ordinal_position;

-- =====================================================================
-- STEP 4: Insert a New Patient (Audit Test)
-- =====================================================================
INSERT INTO dim_patient (patient_id, patient_name, age, gender, hospital_id, admission_date, discharge_date)
VALUES (9999, 'Ravi Kumar', 45, 'Male', 1, '2025-11-10', NULL);

-- Check timestamps after insert
SELECT patient_id, patient_name, created_at, updated_at
FROM dim_patient
WHERE patient_id = 9999;

-- =====================================================================
-- STEP 5: Update Patient Record (Simulate Audit Trail)
-- =====================================================================
UPDATE dim_patient
SET discharge_date = '2025-11-15',
    updated_at = GETDATE()
WHERE patient_id = 9999;

-- Check timestamps after update
SELECT patient_id, patient_name, created_at, updated_at
FROM dim_patient
WHERE patient_id = 9999;

-- =====================================================================
-- STEP 6: Metadata Validation Queries
-- =====================================================================
-- Count tables and row loads
SELECT 
    (SELECT COUNT(*) FROM dim_country) AS country_count,
    (SELECT COUNT(*) FROM dim_city) AS city_count,
    (SELECT COUNT(*) FROM dim_hospital) AS hospital_count,
    (SELECT COUNT(*) FROM dim_patient) AS patient_count;


-- =====================================================================
-- END OF SCRIPT
-- =====================================================================

