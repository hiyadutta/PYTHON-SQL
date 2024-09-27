CREATE DATABASE retail;
USE retail;


CREATE TABLE df_orders (
[order_id] INT PRIMARY KEY
,[order_date] DATE
,[ship_mode] VARCHAR(20)
,[segment] VARCHAR(20)
,[country] VARCHAR(20)
,[city] VARCHAR(20)
,[state] VARCHAR(20)
,[postal_code] VARCHAR(20)
,[region] VARCHAR(20)
,[category] VARCHAR(50)
,[sub_category] VARCHAR(20)
,[product_id] VARCHAR(50)
,[quantity] INT
,[discount] DECIMAL(7,2)
,[sale_price] DECIMAL(7,2)
,[profit] DECIMAL(7,2));


SELECT * FROM df_orders;

-- Top 10 revenue 

SELECT TOP 10 product_id, 
	category, 
	SUM(sale_price) AS sales 
FROM df_orders
GROUP BY product_id,category 
ORDER BY sales DESC;


-- Top 5 highest selling products in each region
WITH cte AS (
	SELECT region,
	product_id, 
	SUM(sale_price) AS sales 
FROM df_orders
GROUP BY product_id,region)
SELECT * FROM (SELECT *, ROW_NUMBER() OVER (PARTITION BY region ORDER BY sales DESC) AS rn
FROM cte) a
WHERE rn<=5;

-- Find month over month growth comparison for 2022 and 2023 sales eg : jan 2022 vs jan 2023
WITH cte AS (
SELECT YEAR(order_date) AS order_year,
MONTH(order_date) AS order_month,
SUM(sale_price) AS sales
FROM df_orders
GROUP BY YEAR(order_date),MONTH(order_date)
	)
SELECT order_month,
SUM(CASE WHEN order_year = 2022 THEN sales ELSE 0 END) AS '2022_sales',
SUM(CASE WHEN order_year = 2023 THEN sales ELSE 0 END) AS '2023_sales'
FROM cte
GROUP BY order_month
ORDER BY order_month;

--for each category which month had highest sales 
WITH cte AS(
SELECT 
YEAR(order_date) AS order_year, 
MONTH(order_date) AS month_year, 
category,
SUM(sale_price) AS sales
FROM df_orders
GROUP BY category, YEAR(order_date),MONTH(order_date) )
SELECT * FROM (
SELECT *,ROW_NUMBER() OVER(PARTITION BY category ORDER BY sales DESC) AS rn
FROM cte) a
WHERE rn=1;


--which sub category had highest growth by profit in 2023 compare to 2022

WITH cte AS (
SELECT 
YEAR(order_date) AS order_year,  
sub_category,
SUM(profit) AS profits
FROM df_orders 
GROUP BY sub_category, YEAR(order_date)
)
, cte2 AS (
SELECT sub_category, 
SUM(CASE WHEN order_year = 2023 THEN profits ELSE 0 END) AS [2023_profit],
SUM(CASE WHEN order_year = 2022 THEN profits ELSE 0 end) AS [2022_profit]
FROM cte
GROUP BY sub_category
)
SELECT TOP 1 *, (([2023_profit]-[2022_profit])*100)/[2022_profit] AS [growth_%]
FROM cte2
ORDER BY [growth_%] DESC;








  