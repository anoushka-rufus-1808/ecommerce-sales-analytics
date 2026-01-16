--analysis queries
-- Question 1: Monthly Revenue Trend
-- Business context: Track revenue growth/decline month-over-month

SELECT 
    strftime('%Y-%m', o.order_purchase_timestamp) AS month,
    ROUND(SUM(p.payment_value), 2) AS monthly_revenue,
    COUNT(DISTINCT o.order_id) AS orders_count
FROM olist_order_payments_dataset p
JOIN olist_orders_dataset o ON p.order_id = o.order_id
WHERE o.order_status = 'delivered'
GROUP BY month
ORDER BY month;

-- Question 2: Revenue by Product Category
-- Business context: Identify top-performing product lines

SELECT 
    pr.product_category_name AS category,
    ROUND(SUM(p.payment_value), 2) AS category_revenue,
    COUNT(DISTINCT oi.order_id) AS orders_count,
    ROUND(AVG(p.payment_value), 2) AS avg_order_value
FROM olist_order_items_dataset oi
JOIN olist_products_dataset pr ON oi.product_id = pr.product_id
JOIN olist_order_payments_dataset p ON oi.order_id = p.order_id
GROUP BY category
ORDER BY category_revenue DESC
LIMIT 10;

-- Question 3: Repeat vs One-Time Customers
-- Business context: Customer retention and loyalty analysis

SELECT 
    CASE 
        WHEN order_count = 1 THEN 'One-time'
        ELSE 'Repeat'
    END AS customer_type,
    COUNT(*) AS num_customers,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM olist_customers_dataset), 2) AS percentage
FROM (
    SELECT 
        customer_id,
        COUNT(DISTINCT order_id) AS order_count
    FROM olist_orders_dataset
    GROUP BY customer_id
)
GROUP BY customer_type;
-- Check: How many customers actually placed orders? (issue with Q3)
SELECT 
    (SELECT COUNT(DISTINCT customer_id) FROM olist_customers_dataset) AS total_customers,
    (SELECT COUNT(DISTINCT customer_id) FROM olist_orders_dataset) AS customers_who_ordered;
	
-- Question 4: Top 10 Customers by Total Spend
-- Business context: Identify highest-value customers

SELECT 
    o.customer_id,
    ROUND(SUM(p.payment_value), 2) AS total_spend,
    COUNT(DISTINCT o.order_id) AS order_count
FROM olist_orders_dataset o
JOIN olist_order_payments_dataset p ON o.order_id = p.order_id
WHERE o.order_status = 'delivered'
GROUP BY o.customer_id
ORDER BY total_spend DESC
LIMIT 10;

-- Question 5: Order Status Distribution
-- Business context: Understanding delivery success and failure rates

SELECT 
    order_status,
    COUNT(*) AS order_count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM olist_orders_dataset), 2) AS percentage
FROM olist_orders_dataset
GROUP BY order_status
ORDER BY order_count DESC;

-- Question 6: Average Order Value (AOV)
-- Business context: Understanding typical customer spending per order

SELECT 
    ROUND(AVG(payment_value), 2) AS average_order_value,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(SUM(payment_value), 2) AS total_revenue
FROM olist_order_payments_dataset
WHERE payment_type IS NOT NULL;
