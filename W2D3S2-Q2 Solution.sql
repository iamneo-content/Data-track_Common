-- Active: 1759911087247@@127.0.0.1@3306@hr_dwh
-- solution.sql
-- 1) Summary: business keys that map to more than one surrogate key
USE HR_database;
SELECT
  e.employee_code,
  GROUP_CONCAT(DISTINCT e.employee_key ORDER BY e.employee_key) AS employee_keys,
  COUNT(DISTINCT e.employee_key) AS distinct_key_count
FROM dim_employee e
GROUP BY e.employee_code
HAVING COUNT(DISTINCT e.employee_key) > 1
ORDER BY e.employee_code;

SELECT
  e.employee_code,
  e.employee_key,
  e.employee_name,
  e.department,
  e.designation,
  e.location,
  e.joining_date
FROM dim_employee e
JOIN (
  SELECT employee_code
  FROM dim_employee
  GROUP BY employee_code
  HAVING COUNT(DISTINCT employee_key) > 1
) d USING (employee_code)
ORDER BY e.employee_code, e.employee_key;
