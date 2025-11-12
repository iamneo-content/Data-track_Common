-- =====================================================================
-- PRACTICE QUESTION:
-- OPTIMIZE AND MAINTAIN TABLE PERFORMANCE IN REDSHIFT
-- =====================================================================
-- Objective:
--  Demonstrate SORTKEY behavior and block pruning in query plans.
--  Perform VACUUM FULL and ANALYZE to reclaim space and restore order.
-- =====================================================================

-- =====================================================================
-- STEP 1: Drop existing table (if re-run)
-- =====================================================================
DROP TABLE IF EXISTS call_logs_sorted;

-- =====================================================================
-- STEP 2: Create Table with SORTKEY on call_date
-- =====================================================================
CREATE TABLE call_logs_sorted (
    call_id INT,
    customer_id INT,
    agent_id INT,
    call_date DATE,
    duration_seconds INT,
    call_type VARCHAR(20)
)
SORTKEY (call_date);

-- =====================================================================
-- STEP 3: Insert 100 realistic telecom call records (varied scenario)
-- =====================================================================

INSERT INTO call_logs_sorted VALUES
(1, 1001, 301, '2024-01-02', 245, 'Inbound'),
(2, 1002, 302, '2024-01-02', 510, 'Support'),
(3, 1003, 303, '2024-01-03', 365, 'Sales'),
(4, 1004, 304, '2024-01-03', 600, 'Outbound'),
(5, 1005, 305, '2024-01-04', 128, 'Inbound'),
(6, 1006, 306, '2024-01-05', 780, 'Retention'),
(7, 1007, 307, '2024-01-06', 430, 'Sales'),
(8, 1008, 308, '2024-01-06', 310, 'Inbound'),
(9, 1009, 309, '2024-01-07', 640, 'Outbound'),
(10, 1010, 310, '2024-01-08', 155, 'Support'),
(11, 1011, 311, '2024-01-09', 485, 'Inbound'),
(12, 1012, 312, '2024-01-09', 235, 'Outbound'),
(13, 1013, 313, '2024-01-10', 720, 'Sales'),
(14, 1014, 314, '2024-01-10', 95, 'Retention'),
(15, 1015, 315, '2024-01-11', 640, 'Support'),
(16, 1016, 316, '2024-01-12', 270, 'Inbound'),
(17, 1017, 317, '2024-01-13', 505, 'Outbound'),
(18, 1018, 318, '2024-01-14', 325, 'Support'),
(19, 1019, 319, '2024-01-15', 845, 'Inbound'),
(20, 1020, 320, '2024-01-16', 415, 'Sales'),
(21, 1021, 321, '2024-01-17', 110, 'Retention'),
(22, 1022, 322, '2024-01-18', 285, 'Outbound'),
(23, 1023, 323, '2024-01-19', 755, 'Inbound'),
(24, 1024, 324, '2024-01-20', 340, 'Sales'),
(25, 1025, 325, '2024-01-21', 480, 'Support'),
(26, 1026, 326, '2024-01-22', 560, 'Inbound'),
(27, 1027, 327, '2024-01-23', 620, 'Outbound'),
(28, 1028, 328, '2024-01-24', 175, 'Retention'),
(29, 1029, 329, '2024-01-25', 510, 'Sales'),
(30, 1030, 330, '2024-01-26', 395, 'Support'),
(31, 1031, 331, '2024-02-01', 680, 'Inbound'),
(32, 1032, 332, '2024-02-02', 410, 'Outbound'),
(33, 1033, 333, '2024-02-02', 505, 'Sales'),
(34, 1034, 334, '2024-02-03', 310, 'Support'),
(35, 1035, 335, '2024-02-03', 720, 'Retention'),
(36, 1036, 336, '2024-02-04', 180, 'Inbound'),
(37, 1037, 337, '2024-02-04', 265, 'Outbound'),
(38, 1038, 338, '2024-02-05', 590, 'Support'),
(39, 1039, 339, '2024-02-06', 430, 'Inbound'),
(40, 1040, 340, '2024-02-07', 755, 'Sales'),
(41, 1041, 341, '2024-02-07', 315, 'Outbound'),
(42, 1042, 342, '2024-02-08', 505, 'Support'),
(43, 1043, 343, '2024-02-09', 215, 'Inbound'),
(44, 1044, 344, '2024-02-10', 640, 'Outbound'),
(45, 1045, 345, '2024-02-11', 520, 'Support'),
(46, 1046, 346, '2024-02-12', 390, 'Sales'),
(47, 1047, 347, '2024-02-13', 455, 'Inbound'),
(48, 1048, 348, '2024-02-14', 135, 'Retention'),
(49, 1049, 349, '2024-02-15', 810, 'Outbound'),
(50, 1050, 350, '2024-02-16', 265, 'Support'),
(51, 1051, 351, '2024-03-01', 305, 'Inbound'),
(52, 1052, 352, '2024-03-02', 695, 'Outbound'),
(53, 1053, 353, '2024-03-03', 145, 'Retention'),
(54, 1054, 354, '2024-03-04', 520, 'Support'),
(55, 1055, 355, '2024-03-05', 315, 'Inbound'),
(56, 1056, 356, '2024-03-06', 470, 'Sales'),
(57, 1057, 357, '2024-03-07', 710, 'Outbound'),
(58, 1058, 358, '2024-03-08', 365, 'Inbound'),
(59, 1059, 359, '2024-03-09', 600, 'Support'),
(60, 1060, 360, '2024-03-10', 280, 'Inbound'),
(61, 1061, 361, '2024-03-11', 320, 'Sales'),
(62, 1062, 362, '2024-03-12', 760, 'Outbound'),
(63, 1063, 363, '2024-03-13', 430, 'Inbound'),
(64, 1064, 364, '2024-03-14', 175, 'Support'),
(65, 1065, 365, '2024-03-15', 245, 'Retention'),
(66, 1066, 366, '2024-03-16', 410, 'Inbound'),
(67, 1067, 367, '2024-03-17', 285, 'Outbound'),
(68, 1068, 368, '2024-03-18', 325, 'Sales'),
(69, 1069, 369, '2024-03-19', 490, 'Support'),
(70, 1070, 370, '2024-03-20', 700, 'Inbound'),
(71, 1071, 371, '2024-04-01', 175, 'Outbound'),
(72, 1072, 372, '2024-04-02', 600, 'Support'),
(73, 1073, 373, '2024-04-03', 295, 'Inbound'),
(74, 1074, 374, '2024-04-04', 455, 'Retention'),
(75, 1075, 375, '2024-04-05', 510, 'Outbound'),
(76, 1076, 376, '2024-04-06', 650, 'Sales'),
(77, 1077, 377, '2024-04-07', 335, 'Inbound'),
(78, 1078, 378, '2024-04-08', 280, 'Outbound'),
(79, 1079, 379, '2024-04-09', 570, 'Support'),
(80, 1080, 380, '2024-04-10', 435, 'Inbound'),
(81, 1081, 381, '2024-05-01', 260, 'Sales'),
(82, 1082, 382, '2024-05-02', 545, 'Outbound'),
(83, 1083, 383, '2024-05-03', 190, 'Inbound'),
(84, 1084, 384, '2024-05-04', 420, 'Support'),
(85, 1085, 385, '2024-05-05', 340, 'Outbound'),
(86, 1086, 386, '2024-05-06', 790, 'Inbound'),
(87, 1087, 387, '2024-05-07', 385, 'Retention'),
(88, 1088, 388, '2024-05-08', 490, 'Support'),
(89, 1089, 389, '2024-05-09', 325, 'Sales'),
(90, 1090, 390, '2024-05-10', 180, 'Outbound'),
(91, 1091, 391, '2024-06-01', 395, 'Inbound'),
(92, 1092, 392, '2024-06-02', 620, 'Support'),
(93, 1093, 393, '2024-06-03', 305, 'Retention'),
(94, 1094, 394, '2024-06-04', 525, 'Outbound'),
(95, 1095, 395, '2024-06-05', 445, 'Inbound'),
(96, 1096, 396, '2024-06-06', 615, 'Support'),
(97, 1097, 397, '2024-06-07', 235, 'Outbound'),
(98, 1098, 398, '2024-06-08', 355, 'Inbound'),
(99, 1099, 399, '2024-06-09', 780, 'Sales'),
(100, 1100, 400, '2024-06-10', 405, 'Support');

-- =====================================================================
-- STEP 4: Test SORTKEY behavior and query performance
-- =====================================================================

-- View total records
SELECT COUNT(*) AS total_rows FROM call_logs_sorted;

-- Filtered query (should leverage SORTKEY block pruning)
EXPLAIN SELECT * 
FROM call_logs_sorted 
WHERE call_date BETWEEN '2024-01-01' AND '2024-01-31';

-- Unfiltered query (full table scan)
EXPLAIN SELECT * 
FROM call_logs_sorted;

-- Compare actual run times (optional)
SELECT COUNT(*) FROM call_logs_sorted WHERE call_date BETWEEN '2024-01-01' AND '2024-01-31';
SELECT COUNT(*) FROM call_logs_sorted;


-- =====================================================================
-- STEP 5: Delete ~20% of older records
-- =====================================================================

-- Delete older call history
DELETE FROM call_logs_sorted
WHERE call_date < '2024-03-01';

-- Verify logical row count
SELECT COUNT(*) AS after_delete FROM call_logs_sorted;

-- Capture table metrics before VACUUM
SELECT 'Before VACUUM' AS stage,
       "table", size, unsorted, stats_off
FROM svv_table_info
WHERE "table" = 'call_logs_sorted';


-- =====================================================================
-- STEP 6: Perform VACUUM FULL and ANALYZE
-- =====================================================================

-- Physically reclaim deleted space
VACUUM FULL call_logs_sorted;

-- Refresh statistics to fix stats_off = 100
ANALYZE call_logs_sorted;

-- Verify record count remains the same (logical rows)
SELECT COUNT(*) AS after_vacuum FROM call_logs_sorted;

-- Capture table metrics after VACUUM and ANALYZE
SELECT 'After VACUUM' AS stage,
       "table", size, unsorted, stats_off
FROM svv_table_info
WHERE "table" = 'call_logs_sorted';


-- =====================================================================
-- STEP 7: Optional — Demonstrate improved pruning post-maintenance
-- =====================================================================

EXPLAIN SELECT * 
FROM call_logs_sorted 
WHERE call_date BETWEEN '2024-06-01' AND '2024-06-10';
