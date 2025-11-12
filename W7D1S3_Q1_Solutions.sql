-- =====================================================================
-- PRACTICE QUESTION:
-- ANALYZE CUSTOMER ENGAGEMENT USING FULL OUTER JOIN, DISTINCT & SUBQUERY
-- =====================================================================

-- =====================================================================
-- STEP 1: Drop existing tables
-- =====================================================================
DROP TABLE IF EXISTS web_visitors;
DROP TABLE IF EXISTS purchase_orders;

-- =====================================================================
-- STEP 2: Create tables
-- =====================================================================
CREATE TABLE web_visitors (
    visitor_id INT,
    visitor_name VARCHAR(50),
    city VARCHAR(50),
    visit_date DATE,
    pages_viewed INT
);

CREATE TABLE purchase_orders (
    order_id INT,
    visitor_id INT,
    product_category VARCHAR(30),
    amount NUMERIC(10,2),
    order_date DATE
);

-- =====================================================================
-- STEP 3: Insert sample data (50 rows total)
-- =====================================================================

INSERT INTO web_visitors VALUES
(1,'Ravi','Chennai','2024-01-01',8),
(2,'Sneha','Delhi','2024-01-02',5),
(3,'Amit','Pune','2024-01-03',6),
(4,'Neha','Kolkata','2024-01-04',9),
(5,'Kiran','Bangalore','2024-01-05',4),
(6,'Rahul','Hyderabad','2024-01-06',7),
(7,'Meena','Chennai','2024-01-07',10),
(8,'Anuj','Pune','2024-01-08',3),
(9,'Deepa','Delhi','2024-01-09',6),
(10,'Sanjay','Kolkata','2024-01-10',5),
(11,'Pooja','Mumbai','2024-01-11',12),
(12,'Manoj','Delhi','2024-01-12',8),
(13,'Priya','Chennai','2024-01-13',4),
(14,'Abhi','Pune','2024-01-14',5),
(15,'Isha','Bangalore','2024-01-15',9),
(16,'Tara','Delhi','2024-01-16',7),
(17,'Raj','Hyderabad','2024-01-17',6),
(18,'Suresh','Kolkata','2024-01-18',5),
(19,'Gita','Bangalore','2024-01-19',11),
(20,'Harsha','Chennai','2024-01-20',4),
(21,'Rohit','Pune','2024-01-21',8),
(22,'Nisha','Delhi','2024-01-22',5),
(23,'Sunil','Bangalore','2024-01-23',6),
(24,'Ravi','Hyderabad','2024-01-24',9),
(25,'Preeti','Kolkata','2024-01-25',3),
(26,'Ramesh','Delhi','2024-01-26',7),
(27,'Megha','Pune','2024-01-27',5),
(28,'Arjun','Chennai','2024-01-28',10),
(29,'Divya','Bangalore','2024-01-29',6),
(30,'Anita','Delhi','2024-01-30',8),
(31,'Vijay','Hyderabad','2024-01-31',9),
(32,'Kavya','Kolkata','2024-02-01',4),
(33,'Mohan','Pune','2024-02-02',5),
(34,'Snehal','Bangalore','2024-02-03',11),
(35,'Pankaj','Delhi','2024-02-04',6),
(36,'Kritika','Chennai','2024-02-05',7),
(37,'Lokesh','Hyderabad','2024-02-06',3),
(38,'Simran','Delhi','2024-02-07',5),
(39,'Yash','Pune','2024-02-08',8),
(40,'Reema','Bangalore','2024-02-09',10),
(41,'Nikhil','Chennai','2024-02-10',6),
(42,'Payal','Pune','2024-02-11',7),
(43,'Alok','Delhi','2024-02-12',8),
(44,'Sneha','Bangalore','2024-02-13',5),
(45,'Ritu','Kolkata','2024-02-14',4),
(46,'Arav','Chennai','2024-02-15',9),
(47,'Vikas','Pune','2024-02-16',6),
(48,'Monica','Delhi','2024-02-17',8),
(49,'Varun','Bangalore','2024-02-18',5),
(50,'Lakshmi','Hyderabad','2024-02-19',7);

INSERT INTO purchase_orders VALUES
(1001,1,'Electronics',450.00,'2024-01-02'),
(1002,2,'Books',120.00,'2024-01-05'),
(1003,3,'Fashion',310.50,'2024-01-06'),
(1004,4,'Grocery',180.25,'2024-01-07'),
(1005,6,'Fashion',220.00,'2024-01-08'),
(1006,7,'Electronics',999.99,'2024-01-09'),
(1007,8,'Books',90.00,'2024-01-10'),
(1008,10,'Fashion',400.00,'2024-01-12'),
(1009,11,'Grocery',250.75,'2024-01-13'),
(1010,12,'Books',160.20,'2024-01-15'),
(1011,13,'Fashion',280.40,'2024-01-16'),
(1012,15,'Grocery',190.00,'2024-01-17'),
(1013,16,'Fashion',360.00,'2024-01-18'),
(1014,18,'Electronics',850.00,'2024-01-20'),
(1015,20,'Fashion',240.00,'2024-01-22'),
(1016,22,'Books',300.00,'2024-01-23'),
(1017,24,'Electronics',780.00,'2024-01-24'),
(1018,25,'Grocery',90.50,'2024-01-26'),
(1019,27,'Books',130.00,'2024-01-27'),
(1020,28,'Fashion',330.00,'2024-01-28'),
(1021,31,'Electronics',420.00,'2024-01-30'),
(1022,35,'Books',150.00,'2024-02-01'),
(1023,38,'Grocery',230.00,'2024-02-03'),
(1024,40,'Fashion',375.00,'2024-02-04'),
(1025,43,'Electronics',560.00,'2024-02-05');

-- =====================================================================
-- STEP 4: Combine visitor + purchase data into a Customer Engagement Summary
-- =====================================================================

SELECT DISTINCT
    v.visitor_id,
    v.visitor_name,
    v.city,
    MAX(v.visit_date) AS last_visit,
    MAX(p.order_date) AS last_order,
    (
        SELECT COUNT(*) 
        FROM purchase_orders sub 
        WHERE sub.visitor_id = v.visitor_id
    ) AS total_orders,
    SUM(p.amount) AS total_spent
FROM web_visitors v
FULL OUTER JOIN purchase_orders p
    ON v.visitor_id = p.visitor_id
GROUP BY v.visitor_id, v.visitor_name, v.city
ORDER BY total_spent DESC NULLS LAST
LIMIT 10;

-- =====================================================================
-- EXPECTED OUTPUT: Top 10 engaged customers
-- Columns: visitor_id, visitor_name, city, last_visit, last_order,
--           total_orders, total_spent
-- =====================================================================
