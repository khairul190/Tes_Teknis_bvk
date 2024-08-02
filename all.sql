-- MSSQL --

--================== DDL ===============
CREATE DATABASE dwh_ecommerce;
use dwh_ecommerce;
create schema ecommerce;


CREATE OR REPLACE TABLE dwh_ecommerce.ecommerce.categories (
    category_id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    category_name VARCHAR(100) NOT NULL
);


CREATE TABLE dwh_ecommerce.ecommerce.products (
    product_id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    product_name VARCHAR(100) NOT NULL,
    category_id UNIQUEIDENTIFIER ,
    inventory_id UNIQUEIDENTIFIER ,
    discount_id UNIQUEIDENTIFIER,
    price DECIMAL(18, 2) NOT NULL,
);


CREATE TABLE dwh_ecommerce.ecommerce.inventory (
	inventory_id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    stock_quantity INT NOT NULL,
);


CREATE TABLE dwh_ecommerce.ecommerce.products_discount (
	discount_id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
	discount_name varchar(100),
	discount_percent int,
	deleted_at datetime

);


CREATE TABLE dwh_ecommerce.ecommerce.customers (
    customer_id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    customer_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL,
    phone VARCHAR(20),
    address_id UNIQUEIDENTIFIER
);


CREATE TABLE dwh_ecommerce.ecommerce.customers_address (
    address_id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    address_line VARCHAR(255),
    city VARCHAR(100),
    province VARCHAR(20)
);


CREATE TABLE dwh_ecommerce.ecommerce.couriers (
    courier_id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    courier_name VARCHAR(50) NOT NULL
);

CREATE TABLE dwh_ecommerce.ecommerce.orders (
    order_id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    customer_id UNIQUEIDENTIFIER,
    order_date DATE NOT NULL,
);


CREATE TABLE dwh_ecommerce.ecommerce.shipments (
    shipment_id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    order_id UNIQUEIDENTIFIER,
    shipment_date DATE NOT NULL,
    courier_id UNIQUEIDENTIFIER,
    tracking_number UNIQUEIDENTIFIER,
    status VARCHAR(50),
);


CREATE TABLE dwh_ecommerce.ecommerce.order_items (
    order_item_id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    order_id UNIQUEIDENTIFIER,
    product_id UNIQUEIDENTIFIER,
    quantity INT NOT NULL,
    price DECIMAL(18, 2) NOT NULL,
);


-- Create appropriate indexes to improve query performance.
CREATE NONCLUSTERED INDEX idx_products_category
ON dwh_ecommerce.ecommerce.products (category_id, product_name, inventory_id, discount_id);

CREATE NONCLUSTERED INDEX idx_orders_customer
ON dwh_ecommerce.ecommerce.orders (customer_id, order_date);

CREATE NONCLUSTERED INDEX idx_order_items
ON dwh_ecommerce.ecommerce.order_items (product_id, order_id);

CREATE NONCLUSTERED INDEX idx_customers_address
ON dwh_ecommerce.ecommerce.customers_address (city, province);

CREATE NONCLUSTERED INDEX idx_customers
ON dwh_ecommerce.ecommerce.customers (customer_name);

CREATE NONCLUSTERED INDEX idx_shipments
ON dwh_ecommerce.ecommerce.shipments (order_id, shipment_date, courier_id, status);

CREATE NONCLUSTERED INDEX idx_couriers
ON dwh_ecommerce.ecommerce.couriers (courier_name);

CREATE NONCLUSTERED INDEX idx_inventory
ON dwh_ecommerce.ecommerce.inventory (stock_quantity);

CREATE NONCLUSTERED INDEX idx_categories
ON dwh_ecommerce.ecommerce.categories (category_name);

--=================== DML =======================
INSERT INTO ecommerce.couriers (courier_name) VALUES ('JNT'), ('JNE'), ('TIKI');

--Update the inventory quantity after an order is placed.
CREATE TRIGGER trg_UpdateInventory
ON dwh_ecommerce.ecommerce.order_items AFTER
INSERT AS BEGIN UPDATE i

SET i.stock_quantity = CASE WHEN i.stock_quantity - ins.quantity < 0 THEN 0 ELSE i.stock_quantity - ins.quantity END
FROM dwh_ecommerce.ecommerce.inventory i
INNER JOIN ecommerce.products p
ON i.inventory_id = p.inventory_id

INNER JOIN inserted ins
ON p.product_id = ins.product_id END;


--Retrieve the list of all products along with their categories.
SELECT  p.product_name
       ,c.category_name
FROM dwh_ecommerce.ecommerce.products p
LEFT JOIN dwh_ecommerce.ecommerce.categories c
ON p.category_id = c.category_id

--Calculate the total sales amount for each product.
SELECT  p.product_name
       ,COALESCE(SUM(oi.quantity),0) AS quanitity_sold
       ,COALESCE(SUM(oi.price),0)    AS total_sales
FROM dwh_ecommerce.ecommerce.products p
LEFT JOIN dwh_ecommerce.ecommerce.order_items oi
ON oi.product_id = p.product_id
GROUP BY  p.product_name



--Calculate the total number of orders placed by each customer.
SELECT  c.customer_name
       ,COUNT(o.order_id) AS total_order
FROM dwh_ecommerce.ecommerce.customers c
INNER JOIN dwh_ecommerce.ecommerce.orders o
ON c.customer_id = o.customer_id
GROUP BY  c.customer_name


--Find the category with the highest total sales amount.
WITH Ranked_categories as
(
	SELECT  c.category_name
	       ,SUM(oi.price)                                   AS highest_total_sales_amount
	       ,DENSE_RANK() OVER(ORDER BY  SUM(oi.price) DESC) AS rank
	FROM dwh_ecommerce.ecommerce.categories c
	INNER JOIN dwh_ecommerce.ecommerce.products p
	ON c.category_id = p.category_id
	INNER JOIN dwh_ecommerce.ecommerce.order_items oi
	ON p.product_id = oi.product_id
	GROUP BY  c.category_name
)
SELECT  *
FROM Ranked_categories
WHERE rank = 1;

--Retrieve the list of products that are out of stock
SELECT  p.product_name
       ,CASE WHEN i.stock_quantity = 0 or i.stock_quantity is null THEN 'Out of stock'  ELSE Cast(i.stock_quantity AS varchar) END AS STOCK
FROM dwh_ecommerce.ecommerce.products p
INNER JOIN dwh_ecommerce.ecommerce.inventory i
ON p.inventory_id = i.inventory_id
WHERE i.stock_quantity is null or i.stock_quantity = 0;


-- Find the top 3 best-selling products by quantity sold.
WITH RankedProducts AS
(
	SELECT  p.product_name
	       ,COALESCE (SUM(oi.quantity),0)                      AS qty_sold
	       ,DENSE_RANK() OVER(ORDER BY  SUM(oi.quantity) DESC) AS rank_by_QtySold
	FROM dwh_ecommerce.ecommerce.products p
	LEFT JOIN dwh_ecommerce.ecommerce.order_items oi
	ON p.product_id = oi.product_id
	GROUP BY  p.product_name
)
SELECT  product_name
       ,qty_sold
       ,rank_by_QtySold
FROM RankedProducts
WHERE rank_by_QtySold <= 3
AND qty_sold <> 0;


-- Calculate the total revenue generated for each customer.
WITH orders_join AS
(
	SELECT  o.customer_id
	       ,oi.price
	FROM dwh_ecommerce.ecommerce.orders o
	INNER JOIN dwh_ecommerce.ecommerce.order_items oi
	ON o.order_id = oi.order_id
)
SELECT  c.customer_name
       ,COALESCE(SUM(oj.price),0) AS total_revenue
FROM orders_join oj
RIGHT JOIN dwh_ecommerce.ecommerce.customers c
ON oj.customer_id = c.customer_id
GROUP BY  c.customer_name;


--Generate a monthly sales trend report for the current year, showing the total sales amount for each month
SELECT  YEAR(o.order_date)  AS tahun
       ,MONTH(o.order_date) AS bulan
       ,SUM(oi.price)       AS total_sales
FROM dwh_ecommerce.ecommerce.orders o
INNER JOIN dwh_ecommerce.ecommerce.order_items oi
ON o.order_id = oi.order_id
WHERE YEAR(o.order_date) = year(GETDATE())
GROUP BY  year(o.order_date)
         ,MONTH(o.order_date);


-- Find the top 1 couriers used by customer.
WITH RankedCoriers AS
(
	SELECT  c.courier_name
	       ,COUNT(s.order_id)                                   AS qty_used
	       ,DENSE_RANK() OVER(ORDER BY  COUNT(s.order_id) DESC) AS rank
	FROM dwh_ecommerce.ecommerce.couriers c
	INNER JOIN dwh_ecommerce.ecommerce.shipments s
	ON c.courier_id = s.courier_id
	GROUP BY  c.courier_name
)
SELECT  courier_name
       ,qty_used
       ,rank
FROM RankedCoriers
WHERE rank = 1
ORDER BY qty_used DESC;


-- Check Product stock
SELECT  p.product_name
       ,i.stock_quantity
       ,SUM(oi.quantity) AS total_quantity_sold
FROM dwh_ecommerce.ecommerce.inventory i
INNER JOIN dwh_ecommerce.ecommerce.products p
ON i.inventory_id = p.inventory_id
INNER JOIN dwh_ecommerce.ecommerce.order_items oi
ON p.product_id = oi.product_id
GROUP BY  p.product_name
         ,i.stock_quantity
ORDER BY  i.stock_quantity ASC;



-- TOTAL REVENUE BY PRODUCTS
SELECT
    p.product_name,
    SUM(oi.quantity) AS total_quantity_sold,
    SUM(oi.price) AS total_revenue
FROM dwh_ecommerce.ecommerce.products p
INNER JOIN dwh_ecommerce.ecommerce.order_items oi ON p.product_id = oi.product_id
GROUP BY p.product_name
ORDER BY total_revenue DESC;


--monthly sales trend report for every year, showing the total sales amount for each month and product categories
SELECT
    c.category_name,
    YEAR(o.order_date) AS year,
    MONTH(o.order_date) AS month,
    SUM(oi.price * oi.quantity) AS total_sales
FROM dwh_ecommerce.ecommerce.categories c
INNER JOIN dwh_ecommerce.ecommerce.products p ON c.category_id = p.category_id
INNER JOIN dwh_ecommerce.ecommerce.order_items oi ON p.product_id = oi.product_id
INNER JOIN dwh_ecommerce.ecommerce.orders o ON oi.order_id = o.order_id
GROUP BY c.category_name, YEAR(o.order_date), MONTH(o.order_date)
ORDER BY YEAR(o.order_date) ASC;


-- TOTAL REVENUE BY CITY
SELECT 
	ca.city ,
	sum(oi.price) as total_revenue
FROM ecommerce.customers c 
INNER JOIN ecommerce.customers_address ca on c.address_id  = ca.address_id 
INNER JOIN ecommerce.orders o on c.customer_id = o.customer_id 
INNER JOIN ecommerce.order_items oi on o.order_id = oi.order_id 
group by ca.city



-- Best Product in each City by total Revenue
WITH SalesPerProductPerCity AS (
    SELECT 
        ca.city,
        p.product_name,
        SUM(oi.price) AS total_revenue
    FROM dwh_ecommerce.ecommerce.customers c
    INNER JOIN dwh_ecommerce.ecommerce.customers_address ca ON c.address_id = ca.address_id
    INNER JOIN dwh_ecommerce.ecommerce.orders o ON c.customer_id = o.customer_id
    INNER JOIN dwh_ecommerce.ecommerce.order_items oi ON o.order_id = oi.order_id
    INNER JOIN dwh_ecommerce.ecommerce.products p ON oi.product_id = p.product_id
    GROUP BY ca.city, p.product_name
),
MaxSalesPerCity AS (
    SELECT
        city,
        MAX(total_revenue) AS max_revenue
    FROM SalesPerProductPerCity
    GROUP BY city
)
SELECT 
    spc.city,
    spc.product_name,
    spc.total_revenue
FROM SalesPerProductPerCity spc
INNER JOIN MaxSalesPerCity mspc ON spc.city = mspc.city AND spc.total_revenue = mspc.max_revenue;



-- Total revenue for each product if all product sold
WITH ProductLeft AS
(
	SELECT  p.product_name
	       ,i.stock_quantity * (p.price * (1 - pd.discount_percent/100.00)) AS total
	FROM ecommerce.products p
	INNER JOIN ecommerce.inventory i
	ON p.inventory_id = i.inventory_id
	INNER JOIN ecommerce.products_discount pd
	ON p.discount_id = pd.discount_id
), ProductSold AS
(
	SELECT  p.product_name
	       ,SUM(oi.price) AS total
	FROM ecommerce.order_items oi
	INNER JOIN ecommerce.products p
	ON oi.product_id = p.product_id
	GROUP BY  p.product_name
)
SELECT  ps.product_name
       ,pl.total + ps.total AS total
FROM ProductSold ps
INNER JOIN ProductLeft pl
ON ps.product_name = pl.product_name
