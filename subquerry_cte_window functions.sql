Set search_path to assignment;

SUBQUERY QUESTIONS

-- 51. Which customers have spent more than the average spending of all customers?

SELECT c.customer_id, c.first_name, c.last_name
FROM assignment.customers c
JOIN assignment.sales s ON c.customer_id = s.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
HAVING SUM(s.total_amount) > (
    SELECT AVG(total_spent)
    FROM (
        SELECT SUM(total_amount) AS total_spent
        FROM assignment.sales
        GROUP BY customer_id
    ) sub
);

-- 52. Which products are priced higher than the average price of all products?

SELECT product_name, price
FROM assignment.products
WHERE price > (SELECT AVG(price) FROM assignment.products);

-- 53. Which customers have never made a purchase?

SELECT *
FROM assignment.customers
WHERE customer_id NOT IN (
    SELECT DISTINCT customer_id FROM assignment.sales
);

-- 54. Which products have never been sold?

SELECT *
FROM assignment.products
WHERE product_id NOT IN (
    SELECT DISTINCT product_id FROM assignment.sales
);

-- 55. Which customer made the single most expensive purchase (total amount)?

SELECT c.*
FROM assignment.customers c
JOIN assignment.sales s ON c.customer_id = s.customer_id
WHERE s.total_amount = (
    SELECT MAX(total_amount) FROM assignment.sales
);

56-- 56. Which products have total sales greater than the average total sales across all products?

SELECT p.product_name, SUM(s.total_amount) AS total_sales
FROM assignment.products p
JOIN assignment.sales s ON p.product_id = s.product_id
GROUP BY p.product_name
HAVING SUM(s.total_amount) > (
    SELECT AVG(total_sales)
    FROM (
        SELECT SUM(total_amount) AS total_sales
        FROM assignment.sales
        GROUP BY product_id
    ) sub
);

57. -- 57. Which customers registered earlier than the average registration date?

SELECT *
FROM assignment.customers
WHERE registration_date < (
    SELECT TO_TIMESTAMP(AVG(EXTRACT(EPOCH FROM registration_date)))::DATE
    FROM assignment.customers
);
58-- 58. Which products have a price higher than the average price within their own category?

SELECT p.product_name, p.price, p.category
FROM assignment.products p
WHERE p.price > (
    SELECT AVG(price)
    FROM assignment.products
    WHERE category = p.category
);
59.-- 59. Which customers have spent more than the customer with ID = 10?

SELECT c.customer_id, c.first_name, c.last_name
FROM assignment.customers c
JOIN assignment.sales s ON c.customer_id = s.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
HAVING SUM(s.total_amount) > (
    SELECT SUM(total_amount)
    FROM assignment.sales
    WHERE customer_id = 10
);

--60. Which products have total quantity sold greater than the overall average quantity sold?
SELECT p.product_name, SUM(s.quantity_sold) AS total_quantity
FROM assignment.products p
JOIN assignment.sales s ON p.product_id = s.product_id
GROUP BY p.product_name
HAVING SUM(s.quantity_sold) > (
    SELECT AVG(total_qty)
    FROM (
        SELECT SUM(quantity_sold) AS total_qty
        FROM assignment.sales
        GROUP BY product_id
    ) sub
);
-- COMMON TABLE EXPRESSIONS (CTEs)

-- 61. Create an intermediate result that calculates the total amount spent by each customer,
--     then determine which customers are the top 5 highest spenders.

WITH customer_spending AS (
    SELECT customer_id, SUM(total_amount) AS total_spent
    FROM assignment.sales
    GROUP BY customer_id
)
SELECT c.customer_id, c.first_name, c.last_name, cs.total_spent
FROM customer_spending cs
JOIN assignment.customers c ON c.customer_id = cs.customer_id
ORDER BY cs.total_spent DESC
LIMIT 5;
-- 62. Create an intermediate result that calculates total quantity sold per product,
--     then determine which products are the top 3 most sold.
WITH product_sales AS (
    SELECT product_id, SUM(quantity_sold) AS total_quantity
    FROM assignment.sales
    GROUP BY product_id
)
SELECT p.product_name, ps.total_quantity
FROM product_sales ps
JOIN assignment.products p ON p.product_id = ps.product_id
ORDER BY ps.total_quantity DESC
LIMIT 3;
-- 63. Create an intermediate result showing total sales per product category,
--     then determine which category generates the highest revenue.
WITH category_sales AS (
    SELECT p.category, SUM(s.total_amount) AS total_revenue
    FROM assignment.sales s
    JOIN assignment.products p ON p.product_id = s.product_id
    GROUP BY p.category
)
SELECT *
FROM category_sales
ORDER BY total_revenue DESC
LIMIT 1;
-- 64. Create an intermediate result that calculates the number of purchases per customer,
--     then identify customers who purchased more than twice.. Customers with more than 2 purchases
WITH customer_purchases AS (
    SELECT customer_id, COUNT(*) AS purchase_count
    FROM assignment.sales
    GROUP BY customer_id
)
SELECT c.customer_id, c.first_name, c.last_name, cp.purchase_count
FROM customer_purchases cp
JOIN assignment.customers c ON c.customer_id = cp.customer_id
WHERE cp.purchase_count > 2;
-- 65. Create an intermediate result that calculates the total quantity sold per product,
--     then determine which products sold more than the average quantity sold.
WITH product_qty AS (
    SELECT product_id, SUM(quantity_sold) AS total_quantity
    FROM assignment.sales
    GROUP BY product_id
),
avg_qty AS (
    SELECT AVG(total_quantity) AS avg_quantity FROM product_qty
)
SELECT p.product_name, pq.total_quantity
FROM product_qty pq
JOIN assignment.products p ON p.product_id = pq.product_id
WHERE pq.total_quantity > (SELECT avg_quantity FROM avg_qty);
-- 66. Create an intermediate result that calculates total spending per customer,
--     then determine which customers spent more than the average spending.
WITH customer_spending AS (
    SELECT customer_id, SUM(total_amount) AS total_spent
    FROM assignment.sales
    GROUP BY customer_id
),
avg_spending AS (
    SELECT AVG(total_spent) AS avg_spent FROM customer_spending
)
SELECT c.customer_id, c.first_name, c.last_name, cs.total_spent
FROM customer_spending cs
JOIN assignment.customers c ON c.customer_id = cs.customer_id
WHERE cs.total_spent > (SELECT avg_spent FROM avg_spending);
-- 67. Create an intermediate result that calculates total revenue per product,
--     then list the products ordered from highest revenue to lowest.
WITH product_revenue AS (
    SELECT product_id, SUM(total_amount) AS total_revenue
    FROM assignment.sales
    GROUP BY product_id
)
SELECT p.product_name, pr.total_revenue
FROM product_revenue pr
JOIN assignment.products p ON p.product_id = pr.product_id
ORDER BY pr.total_revenue DESC;
-- 68. Create an intermediate result showing monthly sales totals,
--     then determine which month had the highest revenue.
WITH monthly_sales AS (
    SELECT DATE_TRUNC('month', sale_date) AS month,
           SUM(total_amount) AS total_revenue
    FROM assignment.sales
    GROUP BY month
)
SELECT *
FROM monthly_sales
ORDER BY total_revenue DESC
LIMIT 1;
-- 69. Create an intermediate result that calculates the number of sales per product,
--     then determine which products were purchased by more than three customers.
WITH product_customers AS (
    SELECT product_id, COUNT(DISTINCT customer_id) AS customer_count
    FROM assignment.sales
    GROUP BY product_id
)
SELECT p.product_name, pc.customer_count
FROM product_customers pc
JOIN assignment.products p ON p.product_id = pc.product_id
WHERE pc.customer_count > 3;
-- 70. Create an intermediate result showing total quantity sold per product,
--     then identify products that sold less than the average quantity sold.
WITH product_qty AS (
    SELECT product_id, SUM(quantity_sold) AS total_quantity
    FROM assignment.sales
    GROUP BY product_id
),
avg_qty AS (
    SELECT AVG(total_quantity) AS avg_quantity FROM product_qty
)
SELECT p.product_name, pq.total_quantity
FROM product_qty pq
JOIN assignment.products p ON p.product_id = pq.product_id
WHERE pq.total_quantity < (SELECT avg_quantity FROM avg_qty);

-- WINDOW FUNCTION QUESTIONS

-- 71. Rank customers based on the total amount they have spent.

SELECT c.customer_id, c.first_name, c.last_name,
       SUM(s.total_amount) AS total_spent,
       RANK() OVER (ORDER BY SUM(s.total_amount) DESC) AS rank
FROM assignment.customers c
JOIN assignment.sales s ON c.customer_id = s.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name;

-- 72. Rank products based on total quantity sold.
SELECT p.product_id, p.product_name,
       SUM(s.quantity_sold) AS total_quantity,
       RANK() OVER (ORDER BY SUM(s.quantity_sold) DESC) AS rank
FROM assignment.products p
JOIN assignment.sales s ON p.product_id = s.product_id
GROUP BY p.product_id, p.product_name;

-- 73. Identify the 3rd highest spending customer.
WITH ranked_customers AS (
    SELECT c.customer_id, c.first_name, c.last_name,
           SUM(s.total_amount) AS total_spent,
           DENSE_RANK() OVER (ORDER BY SUM(s.total_amount) DESC) AS rank
    FROM assignment.customers c
    JOIN assignment.sales s ON c.customer_id = s.customer_id
    GROUP BY c.customer_id, c.first_name, c.last_name
)
SELECT *
FROM ranked_customers
WHERE rank = 3;

-- 74. Identify the 2nd most expensive product.
SELECT *
FROM (
    SELECT product_id, product_name, price,
           DENSE_RANK() OVER (ORDER BY price DESC) AS rank
    FROM assignment.products
) sub
WHERE rank = 2;

-- 75. Show the ranking of products within each category based on price.
SELECT product_name, category, price,
       RANK() OVER (PARTITION BY category ORDER BY price DESC) AS category_rank
FROM assignment.products;

-- 76. Show the ranking of customers based on the number of purchases they made.
SELECT c.customer_id, c.first_name, c.last_name,
       COUNT(s.sale_id) AS purchase_count,
       RANK() OVER (ORDER BY COUNT(s.sale_id) DESC) AS rank
FROM assignment.customers c
JOIN assignment.sales s ON c.customer_id = s.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name;

-- 77. Show the running total of sales amounts ordered by sale_date.
SELECT sale_id, sale_date, total_amount,
       SUM(total_amount) OVER (ORDER BY sale_date) AS running_total
FROM assignment.sales;

-- 78. Show the previous sale amount for each sale ordered by sale_date.
SELECT sale_id, sale_date, total_amount,
       LAG(total_amount) OVER (ORDER BY sale_date) AS previous_sale
FROM assignment.sales;

-- 79. Show the next sale amount for each sale ordered by sale_date.
SELECT sale_id, sale_date, total_amount,
       LEAD(total_amount) OVER (ORDER BY sale_date) AS next_sale
FROM assignment.sales;

-- 80. Divide customers into 4 groups based on total spending.
SELECT c.customer_id, c.first_name, c.last_name,
       SUM(s.total_amount) AS total_spent,
       NTILE(4) OVER (ORDER BY SUM(s.total_amount) DESC) AS spending_group
FROM assignment.customers c
JOIN assignment.sales s ON c.customer_id = s.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name;


















