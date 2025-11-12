-- =====================================================================
-- STEP 0: Clean up existing tables (drop in dependency-safe order)
-- =====================================================================

DROP TABLE IF EXISTS fact_enrollments;
DROP TABLE IF EXISTS dim_students;
DROP TABLE IF EXISTS dim_courses;
DROP TABLE IF EXISTS dim_instructors;
DROP TABLE IF EXISTS dim_dates;

-- =====================================================================
-- STEP 1: Create Dimension Tables
-- =====================================================================

CREATE TABLE dim_students (
    student_id INT PRIMARY KEY,
    student_name VARCHAR(100),
    email VARCHAR(150),
    country VARCHAR(50),
    join_date DATE
);

CREATE TABLE dim_courses (
    course_id INT PRIMARY KEY,
    course_name VARCHAR(150),
    category VARCHAR(100),
    difficulty VARCHAR(50),
    duration_hours INT
);

CREATE TABLE dim_instructors (
    instructor_id INT PRIMARY KEY,
    instructor_name VARCHAR(100),
    expertise VARCHAR(100),
    experience_years INT,
    country VARCHAR(50)
);

CREATE TABLE dim_dates (
    date_id INT PRIMARY KEY,
    full_date DATE,
    day SMALLINT,
    month SMALLINT,
    month_name VARCHAR(20),
    year SMALLINT,
    weekday VARCHAR(10)
);

-- =====================================================================
-- STEP 2: Create Fact Table (with foreign keys)
-- =====================================================================

CREATE TABLE fact_enrollments (
    enrollment_id BIGINT PRIMARY KEY,
    student_id INT REFERENCES dim_students(student_id),
    course_id INT REFERENCES dim_courses(course_id),
    instructor_id INT REFERENCES dim_instructors(instructor_id),
    date_id INT REFERENCES dim_dates(date_id),
    hours_watched DECIMAL(5,2),
    progress_percent DECIMAL(5,2),
    score DECIMAL(5,2),
    feedback_rating SMALLINT
);

-- =====================================================================
-- STEP 3: Load Data from S3
-- =====================================================================

COPY dim_students
FROM 's3://demo-616700456562/online_courses/dim_students.csv'
IAM_ROLE 'arn:aws:iam::616700456562:role/service-role/AmazonRedshift-CommandsAccessRole-20251112T095845'
CSV
IGNOREHEADER 1
REGION 'us-east-2';

COPY dim_courses
FROM 's3://demo-616700456562/online_courses/dim_courses.csv'
IAM_ROLE 'arn:aws:iam::616700456562:role/service-role/AmazonRedshift-CommandsAccessRole-20251112T095845'
CSV
IGNOREHEADER 1
REGION 'us-east-2';

COPY dim_instructors
FROM 's3://demo-616700456562/online_courses/dim_instructors.csv'
IAM_ROLE 'arn:aws:iam::616700456562:role/service-role/AmazonRedshift-CommandsAccessRole-20251112T095845'
CSV
IGNOREHEADER 1
REGION 'us-east-2';

COPY dim_dates
FROM 's3://demo-616700456562/online_courses/dim_dates.csv'
IAM_ROLE 'arn:aws:iam::616700456562:role/service-role/AmazonRedshift-CommandsAccessRole-20251112T095845'
CSV
IGNOREHEADER 1
REGION 'us-east-2';

COPY fact_enrollments
FROM 's3://demo-616700456562/online_courses/fact_enrollments.csv'
IAM_ROLE 'arn:aws:iam::616700456562:role/service-role/AmazonRedshift-CommandsAccessRole-20251112T095845'
CSV
IGNOREHEADER 1
REGION 'us-east-2';

-- =====================================================================
-- STEP 4: Verify Table Creation
-- =====================================================================

SELECT tablename
FROM pg_table_def
WHERE schemaname = 'public'
ORDER BY tablename;

-- =====================================================================
-- STEP 5: Validate Data (Sample Queries)
-- =====================================================================

-- Join fact with dimensions (preview)
SELECT 
    s.student_name,
    c.course_name,
    i.instructor_name,
    f.progress_percent,
    f.feedback_rating
FROM fact_enrollments f
JOIN dim_students s ON f.student_id = s.student_id
JOIN dim_courses c ON f.course_id = c.course_id
JOIN dim_instructors i ON f.instructor_id = i.instructor_id
LIMIT 10;

-- Aggregation: Top 3 courses by average rating
SELECT 
    c.course_name,
    ROUND(AVG(f.feedback_rating),2) AS avg_rating,
    ROUND(AVG(f.progress_percent),2) AS avg_progress
FROM fact_enrollments f
JOIN dim_courses c ON f.course_id = c.course_id
GROUP BY c.course_name
ORDER BY avg_rating DESC
LIMIT 3;

-- =====================================================================
-- END OF SCRIPT
-- =====================================================================
