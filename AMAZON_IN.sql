-- first import into products,
-- import into customers
-- import into sellers
-- import into orders
-- import into returns


-- creating customers table
DROP TABLE IF EXISTS customers;
CREATE TABLE customers (
                            customer_id VARCHAR(25) PRIMARY KEY,
                            customer_name VARCHAR(25),
                            state VARCHAR(25)
);


-- creating sellers table
DROP TABLE IF EXISTS sellers;
CREATE TABLE sellers (
                        seller_id VARCHAR(25) PRIMARY KEY,
                        seller_name VARCHAR(25)
);


-- creating products table
DROP TABLE IF EXISTS products;
CREATE TABLE products (
                        product_id VARCHAR(25) PRIMARY KEY,
                        product_name VARCHAR(255),
                        Price FLOAT,
                        cogs FLOAT
);



-- creating orders table
DROP TABLE IF EXISTS orders;
CREATE TABLE orders (
                        order_id VARCHAR(25) PRIMARY KEY,
                        order_date DATE,
                        customer_id VARCHAR(25),  -- this is a foreign key from customers(customer_id)
                        state VARCHAR(25),
                        category VARCHAR(25),
                        sub_category VARCHAR(25),
                        product_id VARCHAR(25),   -- this is a foreign key from products(product_id)
                        price_per_unit FLOAT,
                        quantity INT,
                        sale FLOAT,
                        seller_id VARCHAR(25),    -- this is a foreign key from sellers(seller_id)
    
                        CONSTRAINT fk_customers FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
                        CONSTRAINT fk_products FOREIGN KEY (product_id) REFERENCES products(product_id),    
                        CONSTRAINT fk_sellers FOREIGN KEY (seller_id) REFERENCES sellers(seller_id)
);



-- creating returns table
DROP TABLE IF EXISTS returns;
CREATE TABLE returns (
                        order_id VARCHAR(25),
                        return_id VARCHAR(25),
                        CONSTRAINT pk_returns PRIMARY KEY (order_id), -- Primary key constraint
                        CONSTRAINT fk_orders FOREIGN KEY (order_id) REFERENCES orders(order_id)
);




-- Business Problems

-- Q.1 Find out the top 5 sellers who made the highest profits.


SELECT 
	o.seller_id,
	SUM((p.price - p.cogs) * o.quantity) as total_profit
FROM 
	orders as o
JOIN
	products as p
ON p.product_id = o.product_id
GROUP BY
	o.seller_id
ORDER BY
	total_profit DESC
LIMIT 5;



-- Q.Find out the average quantity ordered per category.

SELECT 
category,
AVG(quantity) as avg_quantity
FROM 
orders
WHERE category IS NOT NULL
GROUP BY category;



-- Q.2 Find out the average quantity ordered per category.

SELECT
	category,
	AVG(quantity) as avg_quantity
FROM 
orders
GROUP BY category;




-- Q.3. Identify the top 5 products that have generated the highest revenue.

SELECT
	product_id,
	SUM(sale) as total_sale
FROM orders
GROUP BY
product_id
ORDER BY 
total_sale DESC
LIMIT 5;



-- Q.4. Determine the top 5 products whose revenue has decreased compared to the previous year.
-- Based on the data current year = 2023
-- previous year = 2022


WITH previous_year
AS (
	SELECT 
	product_id,
	SUM(sale) as total_sale_prev_yr
	FROM orders
	WHERE EXTRACT(YEAR from order_date) = EXTRACT(YEAR from current_date) - 2
	GROUP BY product_id
	),

current_year 
AS (
	SELECT 
	product_id,
	SUM(sale) as total_sale_current_yr
	FROM orders
	WHERE EXTRACT(YEAR from order_date) = EXTRACT(YEAR from current_date) - 1
	GROUP BY product_id
	)

SELECT 
ly.product_id,
ly.total_sale_prev_yr,
cy.total_sale_current_yr,
(cy.total_sale_current_yr - ly.total_sale_prev_yr) as rev_decrease
FROM previous_year as ly
JOIN
current_year as cy
ON
ly.product_id = cy.product_id
WHERE ly.total_sale_prev_yr > cy.total_sale_current_yr
ORDER BY rev_decrease 
LIMIT 5;


-- Q.5. Identify the highest profitable sub-category.

SELECT
	o.sub_category, 
	SUM((p.price - p.cogs) * quantity) as profit
FROM
orders as o
JOIN
products as p
ON
o.product_id = p.product_id
WHERE sub_category IS NOT NULL
GROUP BY o.sub_category
ORDER BY
profit DESC



-- Q.6.Find out the states with the highest total orders.

SELECT
	state,
	COUNT(order_id) as order_count
FROM orders
GROUP BY
	state
ORDER BY order_count DESC
;




-- Q.7.Determine the month with the highest number of orders.

SELECT
EXTRACT(MONTH from order_date) as months,
COUNT(order_id) as order_count
FROM
orders
GROUP BY EXTRACT(MONTH from order_date)
ORDER BY order_count DESC
LIMIT 1;



-- Q.8. Calculate the profit margin percentage for each sale (Profit divided by Sales).

SELECT
o.order_id,
((p.price - p.cogs) * quantity) as profit,
(((p.price - p.cogs) * quantity)/o.sale * 100) as profit_margin
FROM 
orders as o
JOIN
products as p
ON
o.product_id = p.product_id;



-- Q.9. Calculate the percentage contribution of each sub-category
-- First calculating subcategory wise sales then calculating total sales with two CTEs
-- Then doing a CROSS JOIN to calculate the percentage contribution of each subcategory

WITH subcategory_sales 
AS (
	SELECT sub_category, 
	SUM(sale) as subcategory_total_sale
	FROM orders
	GROUP BY sub_category
   ),
   
total_sales 
AS (
	SELECT 
	SUM(sale) as overall_total_sales
	FROM orders
	)
SELECT 
s.sub_category,
s.subcategory_total_sale,
t.overall_total_sales,
(s.subcategory_total_sale/t.overall_total_sales) * 100 as contribution_percentage
FROM
subcategory_sales as s
JOIN
total_sales as t
ON
1=1;



-- Q.10. Identify top 2 category that has received maximum returns, also find their return %

SELECT
	o.category,
	COUNT(r.return_id) as return_count,
	COUNT(o.order_id) as order_count,
	(COUNT(r.return_id)* 100.0/COUNT(o.order_id)) as return_percentage
FROM 
	orders as o
LEFT JOIN 
	returns as r
ON 
	o.order_id = r.order_id
WHERE
	category IS NOT NULL
GROUP BY 
	category
ORDER BY 
return_count DESC
LIMIT 2;



SELECT 
CATEGORY,
COUNT(order_id)
	 FROM orders
GROUP BY category	




-- Other Problems


-- 1. What are the total sales made by each customer?

SELECT 
	customer_id,
	SUM(sale) as total_sales
FROM 
	orders
GROUP BY
	customer_id;



--  2. How many unique customers have placed orders?

SELECT 
	COUNT(DISTINCT customer_id)
FROM 
	orders;


-- 3. Which product has the highest sale price?

SELECT 
	product_id,
	sale
FROM 
	orders
ORDER BY sale DESC
LIMIT 1;


-- Q.4. How many orders were placed in each state?

SELECT 
	COUNT(state) as order_count,
	state
FROM 
orders
WHERE state IS NOT NULL
GROUP BY
state;


-- Q.5.What is the total revenue generated from each product category?

SELECT 
category,
SUM(sale) as total_revenue
FROM orders
WHERE category IS NOT NULL
GROUP BY category;


-- Q.6. Which seller has the highest total sales?

SELECT 
o.seller_id,
SUM(o.sale) as total_sales,
s.seller_name
FROM ORDERS as o
JOIN 
sellers as s
ON
o.seller_id = s.seller_id
GROUP BY o.seller_id, s.seller_name
ORDER BY total_sales DESC
LIMIT 1;



-- Q. 7.What is the average quantity of products ordered across order?

SELECT 
AVG(quantity) as avg_quantity
FROM orders;


-- Q.8. Which customer has made the highest total purchase?

SELECT 
customer_id,
SUM(sale) as total_sale
FROM orders
GROUP BY customer_id
ORDER BY total_sale DESC
LIMIT 1;


-- Q.9. How many returns were made for each order?

SELECT 
	o.order_id,
	COUNT(r.return_id) as return_count
FROM returns as r
RIGHT JOIN 
	orders as o
ON
	o.order_id = r.order_id
GROUP BY
	o.order_id;


-- Q.10. What is the total sales revenue generated per month?

SELECT
	EXTRACT(MONTH FROM order_date) as months,
	SUM(sale) as total_sales
FROM
	orders
GROUP BY months;	



-- Q.11.Which product category has the highest average sale price?

SELECT 
	category,
	AVG(sale) as avg_sales
FROM 
	orders
GROUP BY 
	category
ORDER BY 
	avg_sales DESC
LIMIT 1;	



-- Q.12. How many orders were placed for each sub-category?

SELECT
	sub_category,
	COUNT(sub_category) as total_orders
FROM
	orders
WHERE 
	sub_category IS NOT NULL
GROUP BY 
	sub_category;



-- Q.13.What is the total profit margin for each product?

SELECT 
	p.product_id,
	SUM((p.price  - p.cogs) * o.quantity) as profit_margin
FROM products as p
JOIN
orders as o
ON p.product_id = o.product_id
GROUP BY p.product_id;



-- Q.14.Which seller has the highest number of unique customers?

SELECT 
seller_id,
unique_customer_count
FROM
		(SELECT 
		seller_id,
		COUNT(DISTINCT customer_id) as unique_customer_count,
		RANK() OVER(ORDER BY COUNT(DISTINCT customer_id) DESC) as rank
		FROM orders
		GROUP BY seller_id) as ranked_sellers
WHERE rank =1;



-- Q.15 How many orders were placed for each seller?

SELECT 
seller_id,
COUNT(order_id) as order_count
FROM 
orders
GROUP BY seller_id;



-- Q.16.What is the total sales revenue generated per seller?

SELECT
seller_id,
SUM(sale) as sales_revenue
FROM 
orders
GROUP BY seller_id;



-- Q.17.Which product has the highest number of returns?

SELECT 
o.product_id,
COUNT(r.return_id) as return_count
FROM orders as o
LEFT JOIN
returns as r
ON o.order_id = r.order_id
GROUP BY o.product_id
ORDER BY return_count DESC;



-- Q.18.How many unique products were sold?

SELECT 
COUNT(DISTINCT product_id) as product_count
FROM orders;



-- Q.19.What is the average price per unit for each product category?

SELECT 
	category, 
	AVG(price_per_unit) as avg_price
FROM 
	orders
WHERE category IS NOT NULL	
GROUP BY
	category
;



-- Q.20.Which state has the highest total sales revenue?

SELECT 
state,
SUM(sale) as total_sale_rev
FROM
orders
GROUP BY state
ORDER BY total_sale_rev DESC
LIMIT 1;


-- Q.21.How many returns were made for each product category?

SELECT
o.category,
COUNT(r.return_id) as return_count
FROM orders as o
JOIN
returns as r
ON o.order_id = r.order_id
GROUP BY o.category;



-- Q.22.What is the total quantity of products sold per seller?

SELECT
seller_id,
SUM(quantity) as quantity_per_seller
FROM orders
GROUP BY seller_id;

--  Q.23.Which customer has placed the most orders?

SELECT
customer_id,
COUNT(order_id) as order_count
FROM orders
GROUP BY
customer_id
ORDER BY order_count DESC
LIMIT 1;

-- Q.24.How many orders were placed for each product?

SELECT
product_id,
COUNT(order_id) as order_count
FROM
orders
GROUP BY
product_id;

--  Q.25.What is the total revenue generated from each seller?

SELECT
seller_id,
SUM(sale) as total_rev
FROM orders
GROUP BY
seller_id;

--  Q.26.Which seller has the highest average sale price?

SELECT
	seller_id,
	AVG(sale) as avg_sale
FROM
	orders
GROUP BY
	seller_id
ORDER BY 
	avg_sale DESC
LIMIT 1;


-- Q. 27.How many unique products were returned?

SELECT 
COUNT(DISTINCT o.product_id) AS unique_products_returned
FROM orders AS o
JOIN returns AS r 
ON
 o.order_id = r.order_id;
	


-- Q.28.What is the total sales revenue generated per product?

SELECT 
product_id,
SUM(sale) as sales_rev
FROM 
orders
GROUP BY product_id;



-- Q.29.Which product category has the highest number of returns?

SELECT
o.category,
COUNT(r.return_id) as return_count
FROM
orders as o
JOIN
returns as r
ON o.order_id = r.order_id
GROUP BY o.category
ORDER BY return_count DESC
LIMIT 1;



-- Q.30.How many orders were placed each month?

SELECT
EXTRACT(MONTH FROM order_date) as months,
COUNT(order_id) as order_count
FROM orders
GROUP BY EXTRACT(MONTH FROM order_date);