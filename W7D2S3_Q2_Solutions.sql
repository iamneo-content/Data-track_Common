-- =====================================================================
-- PRACTICE QUESTION: HEALTHCARE DATA TRANSFORMATION & QUALITY CHECK
-- =====================================================================
-- Scenario:
-- A hospital maintains patient admission data in S3. You must clean,
-- structure, and prepare it for reporting in Redshift.
--
-- S3 Source : s3://lab-rawzone-healthcare/admissions/admissions_raw.csv
-- IAM Role  : arn:aws:iam::616700456562:role/service-role/AmazonRedshift-CommandsAccessRole-20251112T184408
-- =====================================================================

DROP TABLE IF EXISTS fact_admissions_cleaned;
DROP TABLE IF EXISTS stg_admissions;

CREATE TABLE stg_admissions (
    patient_id INT,
    patient_name VARCHAR(100),
    gender VARCHAR(10),
    admission_date DATE,
    discharge_date DATE,
    hospital_id INT,
    diagnosis VARCHAR(200),
    billing_amount NUMERIC(10,2)
);

COPY stg_admissions
FROM 's3://demo-616700456562/admissions/admissions_raw.csv'
IAM_ROLE 'arn:aws:iam::616700456562:role/service-role/AmazonRedshift-CommandsAccessRole-20251112T184408'
CSV
IGNOREHEADER 1
DATEFORMAT 'auto'
REGION 'us-east-2';

SELECT COUNT(*) AS total_raw_records FROM stg_admissions;
SELECT * FROM stg_admissions LIMIT 5;

CREATE TABLE fact_admissions_cleaned (
    patient_id INT PRIMARY KEY,
    patient_name VARCHAR(100),
    gender VARCHAR(10),
    admission_date DATE,
    discharge_date DATE,
    hospital_id INT,
    diagnosis VARCHAR(200),
    billing_amount NUMERIC(10,2),
    created_at TIMESTAMP DEFAULT GETDATE(),
    updated_at TIMESTAMP
);

-- ---------------------------------------------------------------------
-- Clean and insert data (Redshift-compatible version)
-- ---------------------------------------------------------------------
INSERT INTO fact_admissions_cleaned (
    patient_id, patient_name, gender, admission_date, discharge_date,
    hospital_id, diagnosis, billing_amount, updated_at
)
SELECT
    r.patient_id, r.patient_name, r.gender, r.admission_date, r.discharge_date,
    r.hospital_id, r.diagnosis, r.billing_amount,
    CAST(NULL AS TIMESTAMP) AS updated_at
FROM (
    SELECT
        s.patient_id,
        s.patient_name,
        s.gender,
        s.admission_date,
        s.discharge_date,
        s.hospital_id,
        CASE WHEN TRIM(COALESCE(s.diagnosis, '')) = '' THEN 'Unknown'
             ELSE s.diagnosis END AS diagnosis,
        s.billing_amount,
        ROW_NUMBER() OVER (
            PARTITION BY s.patient_id
            ORDER BY s.admission_date DESC NULLS LAST
        ) AS rn
    FROM stg_admissions s
    WHERE s.admission_date IS NOT NULL
      AND s.hospital_id IS NOT NULL
) r
WHERE r.rn = 1;

SELECT
    (SELECT COUNT(*) FROM stg_admissions) AS before_cleaning,
    (SELECT COUNT(*) FROM fact_admissions_cleaned) AS after_cleaning;

SELECT * FROM fact_admissions_cleaned LIMIT 5;

UPDATE fact_admissions_cleaned
SET billing_amount = billing_amount * 1.05,
    updated_at = GETDATE()
WHERE patient_id = (SELECT patient_id FROM fact_admissions_cleaned LIMIT 1);

SELECT patient_id, billing_amount, created_at, updated_at
FROM fact_admissions_cleaned
WHERE updated_at IS NOT NULL;

