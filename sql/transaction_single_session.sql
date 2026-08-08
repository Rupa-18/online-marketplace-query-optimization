SELECT MAX(customer_id) FROM Customer;
INSERT INTO Customer (customer_id,name,email,created_at)
VALUES (100001,'SingleSession User','single@example.com',NOW());

SELECT MAX(order_id) FROM `Order`;
INSERT INTO `Order` (order_id,customer_id,order_date,total_amount)
VALUES (300001,100001,NOW(),200.00);

SELECT MAX(payment_id) FROM Payment;
INSERT INTO Payment (payment_id,order_id,payment_date,payment_method,amount)
VALUES (300001,300001,NOW(),'Cash',200.00);
-- begin a transaction
START TRANSACTION;
UPDATE Payment     -- update the payment amount inside the transaction
SET amount=250.00
WHERE payment_id=300001;
SELECT * FROM Payment WHERE payment_id= 300001;   -- checking value inside the transaction
COMMIT; -- ROLLBACK;
SELECT * FROM Payment WHERE payment_id=300001;    -- checking if the original value 250.00 is saved or not
