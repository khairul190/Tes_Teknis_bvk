-- MSSQL --

--================== DDL ===============
CREATE DATABASE dwh_dev;
use dwh_dev;
create schema ecommerce;

CREATE TABLE dwh_dev.ecommerce.categories (
    category_id VARCHAR(10) PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL
);


CREATE TABLE dwh_dev.ecommerce.products (
    product_id VARCHAR(10) PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    category_id VARCHAR(10),
    price DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (category_id) REFERENCES dwh_dev.ecommerce.categories(category_id)
);


CREATE TABLE dwh_dev.ecommerce.customers (
    customer_id VARCHAR(10) PRIMARY KEY,
    customer_name VARCHAR(10) NOT NULL,
    email VARCHAR(100) NOT NULL,
    phone VARCHAR(20),
    address VARCHAR(255)
);

CREATE TABLE dwh_dev.ecommerce.couriers (
    courier_id VARCHAR(10) PRIMARY KEY,
    courier_name VARCHAR(50) NOT NULL
);


CREATE TABLE dwh_dev.ecommerce.orders (
    order_id VARCHAR(10) PRIMARY KEY,
    customer_id VARCHAR(10),
    order_date DATE NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES dwh_dev.ecommerce.customers(customer_id)
);


CREATE TABLE dwh_dev.ecommerce.shipments (
    shipment_id VARCHAR(10) PRIMARY KEY,
    order_id VARCHAR(10),
    shipment_date DATE NOT NULL,
    courier_id VARCHAR(10),
    tracking_number VARCHAR(50),
    status VARCHAR(50),
    FOREIGN KEY (order_id) REFERENCES dwh_dev.ecommerce.orders(order_id),
    FOREIGN KEY (courier_id) REFERENCES dwh_dev.ecommerce.couriers(courier_id)
);


CREATE TABLE dwh_dev.ecommerce.order_items (
    order_item_id VARCHAR(10) PRIMARY KEY,
    order_id VARCHAR(10),
    product_id VARCHAR(10),
    quantity INT NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES dwh_dev.ecommerce.orders(order_id),
    FOREIGN KEY (product_id) REFERENCES dwh_dev.ecommerce.products(product_id)
);


CREATE TABLE dwh_dev.ecommerce.inventory (
    product_id VARCHAR(10) PRIMARY KEY,
    stock_quantity INT NOT NULL,
    FOREIGN KEY (product_id) REFERENCES dwh_dev.ecommerce.products(product_id)
);



-- Create appropriate indexes to improve query performance.
CREATE INDEX idx_products_category_id ON dwh_dev.ecommerce.products (category_id ASC);
CREATE INDEX idx_orders_customer_id ON dwh_dev.ecommerce.orders (customer_id ASC);
CREATE INDEX idx_order_items ON dwh_dev.ecommerce.order_items (product_id ASC, order_id ASC);


--=================== DML =======================

INSERT INTO dwh_dev.ecommerce.categories (category_id, category_name) VALUES
('CAT001', 'Electronics'),
('CAT002', 'Books'),
('CAT003', 'Clothing');


INSERT INTO dwh_dev.ecommerce.products (product_id, product_name, category_id, price) VALUES
('PROD001', 'Smartphone', 'CAT001', 5000000),       
('PROD002', 'Laptop', 'CAT001', 10000000),          
('PROD003', 'Science Fiction Novel', 'CAT002', 150000), 
('PROD004', 'T-shirt', 'CAT003', 100000);           


INSERT INTO dwh_dev.ecommerce.customers (customer_id, customer_name, email, phone, address) VALUES
('CUS001', 'Khairul', 'muhkhairul190@gmail.com', '082117866140', 'Setiabudi, Jakarta Selatan, Indonesia'),
('CUS002', 'Takdir', 'takdirzd@gmail.com', '081231234123', 'Kuningan, Jakarta Selatan, Indonesia'),
('CUS003', 'Arun', 'arun@gmail.com', '081555234123', 'Kuningan, Jakarta Selatan, Indonesia');

INSERT INTO dwh_dev.ecommerce.orders (order_id, customer_id, order_date) VALUES
('ORD001', 'CUS001', '2024-01-01'),
('ORD002', 'CUS003', '2023-02-01'),
('ORD003', 'CUS003', '2024-03-01'),
('ORD004', 'CUS002', '2022-04-01'),
('ORD005', 'CUS003', '2024-05-01'),
('ORD006', 'CUS001', '2024-06-01'),
('ORD007', 'CUS002', '2024-07-01'),
('ORD008', 'CUS001', '2024-08-01'),
('ORD009', 'CUS003', '2024-08-01'),
('ORD010', 'CUS002', '2024-08-01'),
('ORD011', 'CUS001', '2024-08-01'),
('ORD012', 'CUS003', '2024-08-02');


INSERT INTO ecommerce1.couriers (courier_id, courier_name) VALUES
('COURIER001', 'JNT'),
('COURIER002', 'JNE'),
('COURIER003', 'TIKI');

INSERT INTO ecommerce.shipments (shipment_id, order_id, shipment_date, courier_id, tracking_number, status) VALUES
('SHIP001', 'ORD001', '2024-01-02', 'COURIER001', 'TRK123456789', 'Delivered'),
('SHIP002', 'ORD002', '2023-02-02', 'COURIER002', 'TRK987654321', 'Delivered'),
('SHIP003', 'ORD003', '2024-03-02', 'COURIER003', 'TRK112233445', 'In Transit'),
('SHIP004', 'ORD004', '2022-04-02', 'COURIER001', 'TRK556677889', 'Delivered'),
('SHIP005', 'ORD005', '2024-05-02', 'COURIER002', 'TRK998877665', 'Pending'),
('SHIP006', 'ORD006', '2024-06-02', 'COURIER003', 'TRK123123123', 'Delivered'),
('SHIP007', 'ORD007', '2024-07-02', 'COURIER001', 'TRK321321321', 'Delivered'),
('SHIP008', 'ORD008', '2024-08-02', 'COURIER002', 'TRK654654654', 'In Transit'),
('SHIP009', 'ORD009', '2024-08-02', 'COURIER003', 'TRK789789789', 'Delivered'),
('SHIP010', 'ORD010', '2024-08-02', 'COURIER001', 'TRK111222333', 'Pending'),
('SHIP011', 'ORD011', '2024-08-02', 'COURIER002', 'TRK444555666', 'Delivered'),
('SHIP012', 'ORD012', '2024-08-03', 'COURIER003', 'TRK777888999', 'In Transit');




INSERT INTO dwh_dev.ecommerce.order_items (order_item_id, order_id, product_id, quantity, price) VALUES
('ITEM001', 'ORD001', 'PROD001', 1, 5000000),         
('ITEM002', 'ORD001', 'PROD003', 2, 150000),         
('ITEM003', 'ORD002', 'PROD002', 1, 10000000),       
('ITEM004', 'ORD002', 'PROD004', 3, 100000),
('ITEM005', 'ORD003', 'PROD002', 1, 10000000),
('ITEM006', 'ORD003', 'PROD004', 2, 100000),
('ITEM007', 'ORD004', 'PROD001', 2, 5000000),
('ITEM008', 'ORD005', 'PROD003', 1, 150000),
('ITEM009', 'ORD006', 'PROD004', 1, 100000),
('ITEM010', 'ORD007', 'PROD001', 1, 5000000),
('ITEM011', 'ORD008', 'PROD003', 1, 150000),
('ITEM012', 'ORD009', 'PROD002', 1, 10000000);       


INSERT INTO dwh_dev.ecommerce.inventory (product_id, stock_quantity) VALUES
('PROD001', 50),
('PROD002', 30),
('PROD003', 100),
('PROD004', 0);





--Retrieve the list of all products along with their categories.
SELECT 
	p.product_name,
	c.category_name 
FROM dwh_dev.ecommerce.products p 
LEFT JOIN dwh_dev.ecommerce.categories c ON p.category_id = c.category_id 


--Calculate the total sales amount for each product.
SELECT 
	p.product_name,
	SUM(oi.quantity) AS quanitity_sold,
	SUM(oi.price * oi.quantity) AS total_sales
FROM dwh_dev.ecommerce.products p 
LEFT JOIN dwh_dev.ecommerce.order_items oi ON oi.product_id = p.product_id 
group by p.product_name 



--Calculate the total number of orders placed by each customer.
SELECT 
	c.customer_name,
	count(o.order_id) AS total_order
FROM dwh_dev.ecommerce.customers c  
INNER JOIN dwh_dev.ecommerce.orders o ON c.customer_id = o.customer_id 
group by c.customer_name 


--Find the category with the highest total sales amount.
with Ranked_categories as(
SELECT
	c.category_name,
	SUM(oi.price * oi.quantity) AS highest_total_sales_amount,
	DENSE_RANK() OVER(ORDER BY SUM(oi.price * oi.quantity) DESC) AS rank
FROM dwh_dev.ecommerce.categories c 
INNER JOIN dwh_dev.ecommerce.products p ON c.category_id = p.category_id 
INNER JOIN dwh_dev.ecommerce.order_items oi ON p.product_id = oi.product_id 
GROUP BY c.category_name)
SELECT * from Ranked_categories 
where rank = 1;

--Retrieve the list of products that are out of stock
SELECT 
	p.product_name ,
	CASE WHEN i.stock_quantity = 0 or i.stock_quantity is null then 'Out of stock'
	ELSE Cast(i.stock_quantity AS varchar) END AS STOCK
FROM dwh_dev.ecommerce.products p 
INNER JOIN dwh_dev.ecommerce.inventory i ON p.product_id = i.product_id 
WHERE i.stock_quantity is null or i.stock_quantity = 0;

--Update the inventory quantity after an order is placed.
CREATE TRIGGER trg_UpdateInventory
ON dwh_dev.ecommerce.order_items
AFTER INSERT
AS
BEGIN
    UPDATE i
    SET i.stock_quantity = CASE 
	    						WHEN i.stock_quantity - ins.quantity < 0 THEN 0
    							ELSE i.stock_quantity - ins.quantity END
    FROM dwh_dev.ecommerce.inventory i
    INNER JOIN inserted ins ON i.product_id = ins.product_id
END;


-- Find the top 3 best-selling products by quantity sold.
WITH RankedProducts AS (
    SELECT
        p.product_name,
        SUM(oi.quantity) AS qty_sold,
        DENSE_RANK() OVER(ORDER BY SUM(oi.quantity) DESC) AS rank_by_QtySold
    FROM dwh_dev.ecommerce.products p
    LEFT JOIN dwh_dev.ecommerce.order_items oi ON p.product_id = oi.product_id
    GROUP BY p.product_name
)
SELECT
    product_name,
    qty_sold,
    rank_by_QtySold
FROM RankedProducts
WHERE rank_by_QtySold <= 3;


-- Calculate the total revenue generated by each customer.
WITH orders_join AS (
	SELECT 
		o.customer_id,
		oi.price 
	from dwh_dev.ecommerce.orders o  
	INNER JOIN dwh_dev.ecommerce.order_items oi ON o.order_id = oi.order_id 
) 
SELECT
	c.customer_name,
	SUM(oj.price) AS total_revenue
from orders_join oj
RIGHT join dwh_dev.ecommerce.customers c ON oj.customer_id = c.customer_id 
group by c.customer_name;


--Generate a monthly sales trend report for the current year, showing the total sales amount for each month
SELECT 
	YEAR(o.order_date) AS tahun,
	MONTH(o.order_date) AS bulan,
	SUM(oi.price) AS total_sales
from dwh_dev.ecommerce.orders o 
INNER JOIN dwh_dev.ecommerce.order_items oi ON o.order_id = oi.order_id 
where YEAR(o.order_date) = year(GETDATE())
group by year(o.order_date), MONTH(o.order_date);


-- Find the top 3 couriers used by customer.
WITH RankedCoriers AS (
    SELECT
        c.courier_name ,
        count(s.order_id) AS qty_used,
        DENSE_RANK() OVER(ORDER BY count(s.order_id) DESC) AS rank
    FROM dwh_dev.ecommerce.couriers c
    INNER JOIN dwh_dev.ecommerce.shipments s ON c.courier_id  = s.courier_id 
    GROUP BY c.courier_name 
)
SELECT
    courier_name,
    qty_used,
    rank
FROM RankedCoriers
WHERE rank <= 3
ORDER BY qty_used DESC;


-- Check Product stock
SELECT
    p.product_name,
    i.stock_quantity,
    SUM(oi.quantity) AS total_quantity_sold
FROM dwh_dev.ecommerce.inventory i
INNER JOIN dwh_dev.ecommerce.products p ON i.product_id = p.product_id
INNER JOIN dwh_dev.ecommerce.order_items oi ON p.product_id = oi.product_id
GROUP BY p.product_name, i.stock_quantity
ORDER BY i.stock_quantity ASC;



-- TOTAL REVENUE BY PRODUCTS
SELECT
    p.product_name,
    SUM(oi.quantity) AS total_quantity_sold,
    SUM(oi.price * oi.quantity) AS total_revenue
FROM dwh_dev.ecommerce.products p
INNER JOIN dwh_dev.ecommerce.order_items oi ON p.product_id = oi.product_id
GROUP BY p.product_name
ORDER BY total_revenue DESC;


--monthly sales trend report for every year, showing the total sales amount for each month and year by product categories
SELECT
    c.category_name,
    YEAR(o.order_date) AS year,
    MONTH(o.order_date) AS month,
    SUM(oi.price * oi.quantity) AS total_sales
FROM dwh_dev.ecommerce.categories c
INNER JOIN dwh_dev.ecommerce.products p ON c.category_id = p.category_id
INNER JOIN dwh_dev.ecommerce.order_items oi ON p.product_id = oi.product_id
INNER JOIN dwh_dev.ecommerce.orders o ON oi.order_id = o.order_id
GROUP BY c.category_name, YEAR(o.order_date), MONTH(o.order_date)
ORDER BY YEAR(o.order_date) ASC;

