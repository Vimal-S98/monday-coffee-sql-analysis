-- Monday Coffee SCHEMAS

DROP TABLE IF EXISTS sales;
DROP TABLE IF EXISTS customers;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS city;

-- Import Rules
-- 1st import to city
-- 2nd import to products
-- 3rd import to customers
-- 4th import to sales


CREATE TABLE city
(
	city_id	INT PRIMARY KEY,
	city_name VARCHAR(15),	
	population	BIGINT,
	estimated_rent	FLOAT,
	city_rank INT
);

CREATE TABLE customers
(
	customer_id INT PRIMARY KEY,	
	customer_name VARCHAR(25),	
	city_id INT,
	CONSTRAINT fk_city FOREIGN KEY (city_id) REFERENCES city(city_id)
);


CREATE TABLE products
(
	product_id	INT PRIMARY KEY,
	product_name VARCHAR(35),	
	Price float
);


CREATE TABLE sales
(
	sale_id	INT PRIMARY KEY,
	sale_date	date,
	product_id	INT,
	customer_id	INT,
	total FLOAT,
	rating INT,
	CONSTRAINT fk_products FOREIGN KEY (product_id) REFERENCES products(product_id),
	CONSTRAINT fk_customers FOREIGN KEY (customer_id) REFERENCES customers(customer_id) 
);

-- END of SCHEMAS


SELECT COUNT(*) FROM city;
SELECT COUNT(*) FROM customers;
SELECT COUNT(*) FROM products;
SELECT COUNT(*) FROM sales;


-- Business Problems:

-- 1.Coffee consumers count
-- How many people in each city are estimated to consume coffee, given that 25% of the population does?

SELECT * FROM city;

SELECT  city_name,
		ROUND((population * 0.25) / 1000000, 2) AS coffee_consumers_in_millions,   -- Assuming that 25% population consume
		city_rank
FROM city
ORDER BY 2 DESC;

-- Delhi, mumbai, Kolkata have the highest estimates of coffee consumers


-- -------------------------------------------------------------------------------------------------------------------------


-- 2.Total Revenue from Coffee Sales
-- What is the total revenue generated from coffee sales across all cities in the last quarter of 2023?

SELECT * FROM sales;

-- Total revenue across all cities for last quarter of 2023
SELECT  SUM(total) AS total_revenue_q4_2023
FROM sales
WHERE 	EXTRACT(YEAR FROM sale_date) = 2023
		AND
		EXTRACT(QUARTER FROM sale_date) = 4;

-- Total revenue by city
SELECT
	ci.city_name,
	SUM(s.total) AS revenue
FROM sales AS s 
JOIN customers as c
ON s.customer_id = c.customer_id
JOIN city as ci
ON ci.city_id = c.city_id
WHERE EXTRACT(YEAR FROM s.sale_date) = 2023
		AND
		EXTRACT(QUARTER FROM s.sale_date) = 4
GROUP BY ci.city_name
ORDER BY 2 DESC;

-- Cities Pune, Chennai, and Bangalore have top 3 highest sales in 4th quarter of 2023


-- ------------------------------------------------------------------------------------------


-- 3.Sales Count for Each Product
-- How many units of each coffee product have been sold?

SELECT * FROM sales;
SELECT * FROM products;

SELECT 	p.product_name,
		COUNT(s.sale_id) AS total_orders
FROM products as p
LEFT JOIN sales as s            -- Doing left join to see products even if they have 0 sales
ON s.product_id = p.product_id
GROUP BY p.product_name
ORDER BY 2 DESC;


-- ------------------------------------------------------------------------------------------

--4.Average Sales Amount per City
-- What is the average sales amount per customer in each city?

SELECT * FROM city;
SELECT * FROM customers;
SELECT * FROM sales;

SELECT  ci.city_name,
		SUM(s.total) AS total_revenue,	
		COUNT(DISTINCT s.customer_id) AS total_cust,
		ROUND((SUM(s.total)::NUMERIC) / 
			  (COUNT(DISTINCT s.customer_id)::NUMERIC), 2) 
			   AS avg_sale_per_cust
FROM sales as s
JOIN customers as c
ON s.customer_id = c.customer_id
JOIN city as ci
ON c.city_id = ci.city_id
GROUP BY ci.city_name
ORDER BY 4 DESC;

-- Pune, Chennai, Bangalore are top 3 here

-- --------------------------------------------------------------------------------------


-- 5.City Population and Coffee Consumers (25%)
-- Provide a list of cities along with their populations and estimated coffee consumers.
-- return city_name, total current cx, estimated coffee consumers (25%)

SELECT * FROM city;
SELECT * FROM sales;
SELECT * FROM customers;


WITH city_table AS
(
SELECT  city_name,
		ROUND((population * 0.25)/1000000, 2) AS coffee_consumers
FROM city
),
customer_table AS
(
SELECT  ci.city_name,
		COUNT(DISTINCT c.customer_id) AS unique_cus
FROM sales AS s
JOIN customers AS c
ON s.customer_id = c.customer_id
JOIN city AS ci
ON ci.city_id = c.city_id
GROUP BY ci.city_name
)
SELECT  city_table.city_name,
		city_table.coffee_consumers AS coffee_consumers_in_millions,
		customer_table.unique_cus
FROM city_table
JOIN customer_table
ON city_table.city_name = customer_table.city_name
ORDER BY 2 DESC;


-- -----------------------------------------------------------------------------------------


-- 6.Top Selling Products by City
-- What are the top 3 selling products in each city based on sales volume?

SELECT * FROM products;
SELECT * FROM sales;
SELECT * FROM city;
SELECT * FROM customers;


SELECT * FROM
(
SELECT  ci.city_name,
		p.product_name,
		COUNT(s.sale_id) AS product_count,
		DENSE_RANK() OVER(PARTITION BY ci.city_name ORDER BY COUNT(s.sale_id) DESC) AS rank
FROM sales AS s
JOIN products AS p
ON s.product_id = p.product_id
JOIN customers AS c
ON s.customer_id = c.customer_id
JOIN city AS ci
ON c.city_id = ci.city_id
GROUP BY ci.city_name, p.product_name
) AS ranking_table
WHERE rank <= 3;


-- ------------------------------------------------------------------------------------------------


-- 7.Customer Segmentation by City
-- How many unique customers are there in each city who have purchased coffee products?

SELECT * FROM products;
SELECT * FROM sales;
SELECT * FROM city;
SELECT * FROM customers;


SELECT  ci.city_name,
		COUNT(DISTINCT c.customer_id) AS unique_cus
FROM city AS ci
JOIN customers AS c
ON ci.city_id = c.city_id
JOIN sales AS s
ON s.customer_id = c.customer_id
WHERE s.product_id BETWEEN 1 AND 14
GROUP BY ci.city_name
ORDER BY 2 DESC;


-- -------------------------------------------------------------------------------------


-- 8.Average Sale vs Rent
-- Find each city and their average sale per customer and avg rent per customer

SELECT * FROM sales;
SELECT * FROM city;
SELECT * FROM customers;


WITH city_cte AS
(
SELECT  ci.city_name,
		SUM(s.total) AS total_revenue,
		COUNT(DISTINCT c.customer_id) AS unique_cus,
		ROUND(SUM(s.total)::NUMERIC / COUNT(DISTINCT c.customer_id)::NUMERIC,2) AS avg_sale_per_cus
FROM sales AS s
JOIN customers AS c
ON s.customer_id = c.customer_id
JOIN city AS ci
ON c.city_id = ci.city_id
GROUP BY ci.city_name
),
rent_cte AS
(
SELECT  city_name,
		estimated_rent
FROM city
)
SELECT  ct.city_name,
		ct.total_revenue,
		ct.unique_cus,
		ct.avg_sale_per_cus,
		ROUND(cr.estimated_rent::NUMERIC / ct.unique_cus::NUMERIC, 2) AS avg_rent_per_cus
FROM city_cte AS ct
JOIN rent_cte AS cr
ON ct.city_name = cr.city_name
ORDER BY 4 DESC;


-- ----------------------------------------------------------------------------------------


-- 9.-- Monthly Sales Growth
-- Sales growth rate: Calculate the percentage growth (or decline) in sales over different time periods (monthly)
-- by each city

SELECT * FROM sales;
SELECT * FROM city;
SELECT * FROM customers;



WITH current_sale_cte AS
(
SELECT  ci.city_name,
		EXTRACT(MONTH FROM s.sale_date) AS month,
		EXTRACT(YEAR FROM s.sale_date) AS year,
		SUM(s.total) AS total_sale
FROM sales AS s
JOIN customers AS c
ON s.customer_id = c.customer_id
JOIN city AS ci
ON c.city_id = ci.city_id
GROUP BY ci.city_name, EXTRACT(MONTH FROM s.sale_date), EXTRACT(YEAR FROM s.sale_date)
ORDER BY 1,3,2
),
last_sale_cte AS
(
SELECT  city_name,
		month,
		year,
		total_sale AS cr_month_sale,
		LAG(total_sale, 1) OVER(PARTITION BY city_name ORDER BY year, month) AS last_month_sale
FROM current_sale_cte
)
SELECT  city_name,
		month,
		year,
		cr_month_sale,
		last_month_sale,
		ROUND((cr_month_sale - last_month_sale)::NUMERIC / 
			last_month_sale::NUMERIC * 100, 2) AS growth_ratio
FROM last_sale_cte
WHERE last_month_sale IS NOT NULL;


-- -----------------------------------------------------------------------------------------------------


-- 10.Market Potential Analysis
-- Identify top 3 city based on highest sales, return city name, total sale, total rent, total customers, estimated coffee consumer


SELECT * FROM sales;
SELECT * FROM city;
SELECT * FROM customers;

SELECT *
FROM sales AS s
JOIN customers AS c
ON s.customer_id = c.customer_id
JOIN city AS ci
ON c.city_id = ci.city_id;


WITH city_table AS
(
SELECT  ci.city_name,
		SUM(s.total) AS total_revenue,
		COUNT(DISTINCT c.customer_id) AS unique_cus,
		ROUND(SUM(s.total)::NUMERIC / COUNT(DISTINCT c.customer_id)::NUMERIC, 2) AS avg_sale_per_cus
FROM sales AS s
JOIN customers AS c
ON s.customer_id = c.customer_id
JOIN city AS ci
ON c.city_id = ci.city_id
GROUP BY ci.city_name
ORDER BY 2 DESC
),
city_rent AS
(
SELECT  city_name,
		estimated_rent,
		ROUND((population * 0.25)/1000000, 2) AS est_coffee_consumers_millions
FROM city
)
SELECT  ct.city_name,
		ct.total_revenue,
		cr.estimated_rent AS total_rent,
		ct.unique_cus,
		cr.est_coffee_consumers_millions,
		ct.avg_sale_per_cus,
		ROUND(cr.estimated_rent::NUMERIC / unique_cus::NUMERIC, 2) AS avg_rent_per_cus
FROM city_table AS ct
JOIN city_rent AS cr
ON ct.city_name = cr.city_name
ORDER BY 2 DESC;


-- --------------------------------------------------------------------------------------------------

/*
-- Recomendation
City 1: Pune
	1.Average rent per customer is very low.
	2.Highest total revenue.
	3.Average sales per customer is also high.

City 2: Delhi
	1.Highest estimated coffee consumers at 7.7 million.
	2.Highest total number of customers, which is 68.
	3.Average rent per customer is 330 (still under 500).

City 3: Chennai
	1.Good number of customers.
	2.2nd Largest total revenue.
	3.Relatively low average rent per customer.





































