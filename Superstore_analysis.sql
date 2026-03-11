-- Total Sales, Profit, Orders
SELECT 
ROUND(SUM(s.sales),2) AS total_sales,
ROUND(SUM(s.profit),2) AS total_profit,
COUNT(DISTINCT s.order_id) AS total_orders
FROM sales s;

-- Average Discount
SELECT 
ROUND(AVG(discount),2) AS avg_discount
FROM sales;

-- Sales by Region
SELECT 
c.region,
ROUND(SUM(s.sales),2) AS total_sales
FROM sales s
JOIN orders o ON s.order_id = o.order_id
JOIN customers c ON o.customer_id = c.customer_id
GROUP BY c.region
ORDER BY total_sales DESC;

-- Sales by Customer Segment
SELECT 
c.segment,
ROUND(SUM(s.sales),2) AS total_sales
FROM sales s
JOIN orders o ON s.order_id = o.order_id
JOIN customers c ON o.customer_id = c.customer_id
GROUP BY c.segment
ORDER BY total_sales DESC;

-- Profit by Category
SELECT 
p.category,
ROUND(SUM(s.profit),2) AS total_profit
FROM sales s
JOIN products p ON s.product_id = p.product_id
GROUP BY p.category
ORDER BY total_profit DESC;

-- Profit by Sub-Category
SELECT 
p.sub_category,
ROUND(SUM(s.profit),2) AS total_profit
FROM sales s
JOIN products p ON s.product_id = p.product_id
GROUP BY p.sub_category
ORDER BY total_profit DESC;

-- Top Customers by Sales
WITH customer_sales AS (
SELECT
c.customer_name,
SUM(s.sales) AS total_sales
FROM sales s
JOIN orders o ON s.order_id = o.order_id
JOIN customers c ON o.customer_id = c.customer_id
GROUP BY c.customer_name
)

SELECT
customer_name,
total_sales,
RANK() OVER (ORDER BY total_sales DESC) AS sales_rank
FROM customer_sales
LIMIT 10;

-- Top Products by Sales
WITH product_sales AS (
SELECT
p.product_name,
SUM(s.sales) AS total_sales
FROM sales s
JOIN products p ON s.product_id = p.product_id
GROUP BY p.product_name
)

SELECT
product_name,
total_sales,
RANK() OVER (ORDER BY total_sales DESC) AS product_rank
FROM product_sales
LIMIT 10;

-- Yearly Sales Trend
SELECT
YEAR(o.order_date) AS order_year,
ROUND(SUM(s.sales),2) AS yearly_sales
FROM sales s
JOIN orders o ON s.order_id = o.order_id
GROUP BY order_year
ORDER BY order_year;

-- Running Total Sales
SELECT
o.order_date,
SUM(s.sales) AS daily_sales,
SUM(SUM(s.sales)) OVER (ORDER BY o.order_date) AS running_total_sales
FROM sales s
JOIN orders o ON s.order_id = o.order_id
GROUP BY o.order_date;

-- Loss-Making Products
WITH product_profit AS (
SELECT
p.product_name,
SUM(s.profit) AS total_profit
FROM sales s
JOIN products p ON s.product_id = p.product_id
GROUP BY p.product_name
)

SELECT *
FROM product_profit
WHERE total_profit < 0
ORDER BY total_profit;

-- Most Profitable Product in Each Category
SELECT *
FROM (
SELECT
p.category,
p.product_name, 
SUM(s.profit) AS total_profit,
RANK() OVER (PARTITION BY p.category ORDER BY SUM(s.profit) DESC) AS rank_in_category
FROM sales s
JOIN products p ON s.product_id = p.product_id
GROUP BY p.category, p.product_name
) ranked
WHERE rank_in_category = 1;

-- Discount Impact Analysis
SELECT
discount,
ROUND(SUM(sales),2) AS total_sales,
ROUND(SUM(profit),2) AS total_profit
FROM sales
GROUP BY discount
ORDER BY discount;

-- Final dataset
SELECT
o.order_id,
o.order_date,
o.ship_date,
o.ship_mode,
c.customer_name,
c.segment,
c.region,
c.state,
p.product_name,
p.category,
p.sub_category,
s.sales,
s.quantity,
s.discount,
s.profit
FROM sales s
JOIN orders o ON s.order_id = o.order_id
JOIN customers c ON o.customer_id = c.customer_id
JOIN products p ON s.product_id = p.product_id;

-- Row Count Validation
SELECT COUNT(*) 
FROM sales;

SELECT COUNT(*)
FROM sales s
JOIN orders o ON s.order_id = o.order_id
JOIN customers c ON o.customer_id = c.customer_id
JOIN products p ON s.product_id = p.product_id;

-- Check for NULL Values in Important Fields
SELECT 
COUNT(*) AS missing_values
FROM sales
WHERE sales IS NULL
OR profit IS NULL
OR quantity IS NULL;

-- Check for Negative Profit Transactions
SELECT COUNT(*) AS loss_transactions
FROM sales
WHERE profit < 0;