--=====================================================================
-- Advanced data analysis 
--=====================================================================
-- Analysie sales performance over time
--=====================================================================
SELECT
	YEAR (order_date) AS order_year,
	SUM (sales_amount) as total_sales,
	COUNT (DISTINCT customer_key) AS total_customers,
	COUNT (DISTINCT product_key) AS total_products_sold,
	SUM (sales_quantity) AS total_quantity_sold,
	AVG (sales_price) AS avg_sales_price,
	AVG (DATEDIFF (day, order_date, shipping_date)) AS avg_shipping_time
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY YEAR (order_date)
ORDER BY YEAR (order_date);

SELECT
	YEAR (order_date) AS order_year,
	MONTH (order_date) AS order_month,
	SUM (sales_amount) as total_sales,
	COUNT (DISTINCT customer_key) AS total_customers,
	COUNT (DISTINCT product_key) AS total_products_sold,
	SUM (sales_quantity) AS total_quantity_sold,
	AVG (sales_price) AS avg_sales_price,
	AVG (DATEDIFF (day, order_date, shipping_date)) AS avg_shipping_time
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY MONTH (order_date),YEAR (order_date), MONTH (order_date)
ORDER BY MONTH (order_date),YEAR (order_date);

SELECT
	DATETRUNC (month, order_date) AS order_month,
	SUM (sales_amount) as total_sales,
	COUNT (DISTINCT customer_key) AS total_customers,
	COUNT (DISTINCT product_key) AS total_products_sold,
	SUM (sales_quantity) AS total_quantity_sold,
	AVG (sales_price) AS avg_sales_price,
	AVG (DATEDIFF (day, order_date, shipping_date)) AS avg_shipping_time
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATETRUNC (month, order_date)
ORDER BY DATETRUNC (month, order_date);

SELECT
	FORMAT (order_date, 'yyyy-MMM') AS order_month,
	SUM (sales_amount) as total_sales,
	COUNT (DISTINCT customer_key) AS total_customers,
	COUNT (DISTINCT product_key) AS total_products_sold,
	SUM (sales_quantity) AS total_quantity_sold,
	AVG (sales_price) AS avg_sales_price,
	AVG (DATEDIFF (day, order_date, shipping_date)) AS avg_shipping_time
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY FORMAT (order_date, 'yyyy-MMM')
ORDER BY FORMAT (order_date, 'yyyy-MMM');
--======================================================================
--analyse sales performance by product category and subcategory
--======================================================================
SELECT 
	p.category,
	p.subcategory,
	SUM (s.sales_amount) AS total_category_revenue,
	COUNT (DISTINCT s.customer_key) AS total_category_customers,
	COUNT (DISTINCT s.product_key) AS total_category_products_sold,
	SUM (s.sales_quantity)  AS total_cateory_quantity_sold,
	AVG (s.sales_price) AS avg_category_sales_price
FROM gold.fact_sales s
LEFT JOIN gold.dim_products p
ON p.product_key = s.product_key
WHERE s.order_date IS NOT NULL
GROUP BY p.category, p.subcategory
ORDER BY total_category_revenue DESC;

--=====================================================================
--Cumulative analysis
--=======================================================================
--Calculate the total sales per month and the running total sales over time 

SELECT 
	order_month,
	total_sales,
	SUM (total_sales) OVER (ORDER BY order_month) AS running_total_sales,
	AVG (avg_sales_price) OVER (ORDER BY order_month) AS moving_av_sales_price
FROM
(
	SELECT 
		DATETRUNC (year, order_date) AS order_month,
		SUM (sales_amount) AS total_sales,
		AVG (sales_price) AS avg_sales_price
	FROM gold.fact_sales
	WHERE order_date IS NOT NULL
	GROUP BY DATETRUNC (year, order_date)
) t;

--  Analyse the yearly performance of products by comparing each products sales to both its average sales performance and the previous years' sales
--Can use CTE function
WITH annual_product_sales AS
(
		SELECT 
			YEAR (s.order_date) AS order_year,
			p.product_name,
			SUM (s.sales_amount) AS current_sales
		FROM gold.fact_sales s
		LEFT JOIN gold.dim_products p
		ON p.product_key = s.product_key
		WHERE s.order_date IS NOT NULL
		GROUP BY YEAR (s.order_date), p.product_name
)
SELECT 
	order_year,
	product_name,
	current_sales,
	AVG (current_sales) OVER (PARTITION BY product_name) AS avg_sales,
	current_sales - AVG (current_sales) OVER (PARTITION BY product_name) AS avg_sales_diff,
	CASE
	WHEN current_sales - AVG (current_sales) OVER (PARTITION BY product_name) > 0 THEN 'above_average'
	WHEN current_sales - AVG (current_sales) OVER (PARTITION BY product_name) = 0 THEN 'average'
	ELSE 'below_average'
	END AS avg_change,
	--year-over-year analysis
	LAG (current_sales) OVER (PARTITION BY product_name ORDER BY order_year) AS prev_year_sales,
	current_sales - LAG (current_sales) OVER (PARTITION BY product_name ORDER BY order_year) AS sales_diff_annual,
		CASE
	WHEN current_sales - LAG (current_sales) OVER (PARTITION BY product_name ORDER BY order_year) > 0 THEN 'increased'
	WHEN current_sales - LAG (current_sales) OVER (PARTITION BY product_name ORDER BY order_year) < 0 THEN 'decreased'
	ELSE 'no_change'
	END AS annual_sales_trend
FROM annual_product_sales aps 
ORDER BY product_name, order_year;

-- part-to-whole analysys
--which categories contribute the most to the overall sales

WITH category_sales AS
	(
	SELECT 
		p.category,
		sum (sales_amount ) AS category_sales
	FROM gold.fact_sales s
	LEFT JOIN gold.dim_products p
	ON p.product_key = s.product_key
	GROUP BY category
)

SELECT
	category,
	category_sales,
	SUM (category_sales) OVER() AS total_sales,
	CONCAT (ROUND (CAST (category_sales AS FLOAT)/SUM (category_sales) OVER()*100,2), '%')  AS percentage_contribution
FROM category_sales
ORDER BY category_sales DESC;

/* Segment the products into cost ranges and count how many products fall into each cost range. 
This can help identify which cost ranges are most common and potentially more profitable. */

WITH cost_ranges AS
(
SELECT 
product_key,
product_name,
product_cost,
CASE WHEN product_cost < 100 THEN 'Low Cost'
	 WHEN product_cost >= 100 AND product_cost <1000 THEN 'Mid Cost'
	 WHEN product_cost >= 1000 THEN 'High Cost'
	 ELSE 'Unknown Cost Range'
END AS cost_ranges
FROM gold.dim_products
)
SELECT 
cost_ranges,
COUNT (product_key) AS total_products
FROM cost_ranges
GROUP BY cost_ranges
ORDER BY total_products DESC;

/*-- Group customers into 3 segments by their spending behavious.
VIP Customers: At least 12 months history and more than 5,000 euros in spending.
Regular Customers: At least 12 months hisotry but less than 5,000 euros in spending.
New Customers: Less than 12 months history regardless of spending. 
Find the total number of customers by each group.*/
WITH customer_spending AS
(
SELECT 
	c.customer_key,
	MIN (s.order_date) AS first_order_date,
	MAX (s.order_date) AS last_order_date,
	DATEDIFF (month, MIN (s.order_date), MAX (s.order_date)) AS lifespan,
	SUM (s.sales_amount) AS total_spending
FROM gold.dim_customers c
LEFT JOIN gold.fact_sales s
ON c.customer_key = s.customer_key
GROUP BY 
c.customer_key
)
SELECT 
customer_segment,
COUNT (customer_key) AS total_customers
FROM
(
SELECT
customer_key,
total_spending,
lifespan,
CASE 
WHEN lifespan >= 12 AND total_spending > 5000 THEN 'VIP Customers'
WHEN lifespan >= 12 AND total_spending <= 5000 THEN 'Regular Customers'
ELSE 'New Customers'
END AS customer_segment
FROM customer_spending
) t
GROUP BY customer_segment
ORDER BY total_customers DESC;
