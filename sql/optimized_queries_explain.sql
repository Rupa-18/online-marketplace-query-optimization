-- baseline
-- i want my most frequent customers
EXPLAIN FORMAT=JSON
SELECT c.customer_id,c.name,COUNT(o.order_id) AS total_orders
FROM customer c
JOIN `order` o ON c.customer_id=o.customer_id
GROUP BY c.customer_id
ORDER BY total_orders DESC;

-- optimized
-- i want my most frequent customers(pre-aggregating the order table)
EXPLAIN FORMAT=JSON
SELECT c.customer_id,c.name,o.total_orders
FROM customer c
JOIN (
    SELECT customer_id,COUNT(*) AS total_orders
    FROM `order`
    GROUP BY customer_id
) o ON c.customer_id=o.customer_id
ORDER BY o.total_orders DESC;

-- baseline
-- most popular products/ most sold products
EXPLAIN FORMAT=JSON
SELECT p.product_id, p.name,SUM(oi.quantity) AS total_sold
FROM product p
JOIN orderitem oi ON p.product_id=oi.product_id
GROUP BY p.product_id
ORDER BY total_sold DESC;

-- optimized
-- most popular products/ most sold products
EXPLAIN FORMAT=JSON
WITH total_sales AS (
    SELECT product_id,SUM(quantity) AS total_sold
    FROM orderitem
    GROUP BY product_id
)
SELECT p.product_id,p.name,t.total_sold
FROM product p
JOIN total_sales t ON p.product_id=t.product_id
ORDER BY t.total_sold DESC;

-- baseline
-- highest spending customers
EXPLAIN FORMAT=JSON
SELECT c.customer_id,c.name,SUM(p.amount) AS total_spent
FROM customer c
JOIN `order` o ON c.customer_id=o.customer_id
JOIN payment p ON o.order_id=p.order_id
GROUP BY c.customer_id
ORDER BY total_spent DESC;

-- optimized
-- highest spending customers
EXPLAIN FORMAT=JSON
SELECT c.customer_id,c.name,SUM(po.total_spent) AS total_spent
FROM customer c
JOIN `order` o ON c.customer_id=o.customer_id
JOIN (
    SELECT order_id, SUM(amount) AS total_spent
    FROM payment
    GROUP BY order_id
) po ON o.order_id = po.order_id
GROUP BY c.customer_id
ORDER BY total_spent DESC;

-- baseline
-- customers placed the most orders in the last 6 months
EXPLAIN FORMAT=JSON
SELECT c.customer_id,c.name,COUNT(o.order_id) as total_order
FROM Customer c
JOIN `Order` o ON c.customer_id=o.customer_id
WHERE o.order_date>='2024-12-11'
GROUP BY(customer_id)
order by(total_order) DESC;

-- optimized
-- customers placed the most orders in the last 6 months
EXPLAIN FORMAT=JSON
SELECT c.customer_id,c.name,recent_orders.total_order
FROM Customer c
JOIN (
    SELECT customer_id,COUNT(order_id) AS total_order
    FROM `Order`
    WHERE order_date>=CURDATE()-INTERVAL 6 MONTH
    GROUP BY customer_id
) recent_orders ON c.customer_id=recent_orders.customer_id
ORDER BY recent_orders.total_order DESC;

-- baseline
-- most frequently bought product pair
EXPLAIN FORMAT=JSON
SELECT oi1.product_id AS product_1,oi2.product_id AS product_2,COUNT(*) AS bought_together
FROM Orderitem oi1
JOIN Orderitem oi2 ON oi1.order_id=oi2.order_id AND oi1.product_id<oi2.product_id
GROUP BY oi1.product_id,oi2.product_id
ORDER BY bought_together DESC;

-- optimized
-- most frequently bought product pair
EXPLAIN FORMAT=JSON
SELECT pairs.product_1,pairs.product_2,COUNT(*) AS bought_together
FROM (
    SELECT oi1.order_id,oi1.product_id AS product_1,oi2.product_id AS product_2
    FROM OrderItem oi1
    JOIN OrderItem oi2 
      ON oi1.order_id=oi2.order_id 
     AND oi1.product_id<oi2.product_id
) AS pairs
GROUP BY pairs.product_1,pairs.product_2
ORDER BY bought_together DESC;

-- Total Sales per Category
EXPLAIN FORMAT=JSON
SELECT cat.category_id,cat.category_name,SUM(oi.quantity*oi.price) AS total_sales
FROM category cat
JOIN productcategory pc ON cat.category_id=pc.category_id
JOIN product p ON pc.product_id=p.product_id
JOIN orderitem oi ON p.product_id=oi.product_id
GROUP BY cat.category_id,cat.category_name;

-- optimized
-- Total Sales per Category
EXPLAIN FORMAT=JSON
WITH product_revenue AS (
  SELECT product_id,SUM(quantity*price) AS revenue
  FROM orderitem
  GROUP BY product_id
)
SELECT cat.category_id,cat.category_name,SUM(pr.revenue) AS total_sales
FROM product_revenue pr
JOIN productcategory pc ON pr.product_id=pc.product_id
JOIN category cat ON pc.category_id=cat.category_id
GROUP BY cat.category_id,cat.category_name;

-- Total Payment Per Customer
EXPLAIN FORMAT=JSON
SELECT c.customer_id, c.name,SUM(p.amount) as total_payment 
FROM Customer c 
JOIN `Order` o ON c.customer_id=o.customer_id 
JOIN Payment p ON o.order_id=p.order_id 
GROUP BY c.customer_id;

-- optimized
-- Total Payment Per Customer
EXPLAIN FORMAT=JSON
SELECT payments.customer_id,c.name,payments.total_payment 
FROM (
    SELECT o.customer_id,SUM(p.amount) AS total_payment 
    FROM `Order` o 
    JOIN Payment p ON o.order_id=p.order_id 
    GROUP BY o.customer_id
) AS payments 
JOIN Customer c ON payments.customer_id=c.customer_id;
