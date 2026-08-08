-- btree single
CREATE INDEX idx_order_order_date ON `Order` (order_date);
CREATE INDEX idx_orderitem_quantity ON OrderItem (quantity);
CREATE INDEX idx_product_stock ON Product (stock);
CREATE INDEX idx_product_price ON Product (price);
CREATE INDEX idx_payment_amount ON Payment (amount);

-- btree composite
CREATE INDEX idx_order_customer_date ON `Order` (customer_id,order_date);
CREATE INDEX idx_orderitem_product_quantity ON OrderItem (product_id,quantity);
CREATE INDEX idx_payment_order_amount ON Payment (order_id,amount);
CREATE INDEX idx_review_product_rating ON Review (product_id,rating);

-- partial
ALTER TABLE Product 
ADD COLUMN is_low_stock BOOLEAN GENERATED ALWAYS AS (stock<50) STORED;
CREATE INDEX idx_product_is_low_stock ON Product (is_low_stock);

SHOW INDEXES FROM OrderItem;
SHOW INDEXES FROM Product;
SHOW INDEXES FROM Customer;
SHOW INDEXES FROM `Order`;
SHOW INDEXES FROM Payment;
SHOW INDEXES FROM Review;
SHOW INDEXES FROM Category;
SHOW INDEXES FROM ProductCategory;
