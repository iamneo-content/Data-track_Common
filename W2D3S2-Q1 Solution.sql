-- Active: 1759911087247@@127.0.0.1@3306@product_database

USE product_database;

DELIMITER $$
CREATE TRIGGER trg_product_price_change
AFTER UPDATE ON product_master
FOR EACH ROW
BEGIN
    IF OLD.price <> NEW.price THEN
        INSERT INTO product_audit (product_id, old_price, new_price)
        VALUES (OLD.product_id, OLD.price, NEW.price);
    END IF;
END$$
DELIMITER ;

UPDATE product_master
SET price = 78000.00
WHERE product_name = 'Laptop';

UPDATE product_master
SET price = 36000.00
WHERE product_name = 'Smartphone';

UPDATE product_master SET price = 49000.00 WHERE product_name = 'Refrigerator';
UPDATE product_master SET price = 40000.00 WHERE product_name = 'Dining Table';
UPDATE product_master SET price = 28.00 WHERE product_name = 'Ball Pen';

SELECT 
    a.audit_id,
    p.product_name,
    a.old_price,
    a.new_price,
    a.change_time
FROM product_audit a
JOIN product_master p ON a.product_id = p.product_id
ORDER BY a.audit_id;
