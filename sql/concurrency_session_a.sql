-- adding a customer
INSERT INTO Customer (customer_id,name,email,created_at)
VALUES (100002,'Concurrency Test','concurrency@example.com',NOW());
-- adding an order
INSERT INTO `Order` (order_id,customer_id,order_date, total_amount)
VALUES (300002,100002,NOW(),300.00);
-- adding a payment
INSERT INTO Payment (payment_id,order_id,payment_date,payment_method,amount)
VALUES (300002,300002,NOW(),'Card',300.00);

-- Dirty read simulation
SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
START TRANSACTION;
SELECT amount FROM Payment WHERE payment_id=300002;

-- Non-repeatable read
SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;
START TRANSACTION;
SELECT amount FROM Payment WHERE payment_id=300002;   -- read result=555.00

-- Phantom read
SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;
START TRANSACTION;
SELECT COUNT(*) AS count_before FROM Payment WHERE amount>200;

-- Preventing dirty read using READ COMMITTED
SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;
START TRANSACTION;
SELECT amount FROM Payment WHERE payment_id=300002;

-- Preventing non-repeatable read
SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
START TRANSACTION;
-- second read
SELECT amount FROM Payment WHERE payment_id=300002;

--  Preventing phantom read
SET SESSION TRANSACTION ISOLATION LEVEL SERIALIZABLE;
START TRANSACTION;
-- first read
SELECT COUNT(*) AS count_before FROM Payment WHERE amount>200;



















