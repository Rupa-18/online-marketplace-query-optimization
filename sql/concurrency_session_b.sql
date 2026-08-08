USE mydb;
START TRANSACTION;
UPDATE Payment SET amount=555.00 WHERE payment_id=300002;
COMMIT;

-- Phantom read
START TRANSACTION;
INSERT INTO Customer (customer_id,name,email,created_at)
VALUES (100003,'Phantom Read Test','phantom@example.com',NOW());

INSERT INTO `Order`(order_id,customer_id,order_date,total_amount)
VALUES (300003,100003,NOW(),400.00);

INSERT INTO Payment(payment_id,order_id,payment_date,payment_method,amount)
VALUES (300003,300003,NOW(),'Cash',300.00);
COMMIT;

-- Preventing dirty read
START TRANSACTION;
UPDATE Payment SET amount=999.00 WHERE payment_id=300002;
-- did not commit yet

-- Prevent non-repeatable read
START TRANSACTION;
UPDATE Payment SET amount=666.00 WHERE payment_id=300002;
COMMIT;


--  Preventing phantom read
START TRANSACTION;
INSERT INTO Customer (customer_id,name,email,created_at)
VALUES (100004,'No Phantom','no_phantom@example.com',NOW());

INSERT INTO `Order` (order_id,customer_id,order_date,total_amount)
VALUES (300004,100004,NOW(),400.00);

INSERT INTO Payment (payment_id,order_id,payment_date,payment_method,amount)
VALUES (300004,300004,NOW(),'Cash',300.00);
COMMIT;






































