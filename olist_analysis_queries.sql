CREATE DATABASE olist;

#--- . Delivery performance (late vs. on-time, by month)
SELECT
    DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS order_month,
    ROUND(AVG(o.delivery_days), 1) AS avg_delivery_days,
    SUM(CASE WHEN o.delivered_late = 1 THEN 1 ELSE 0 END) AS late_orders,
    COUNT(*) AS total_orders,
    ROUND(SUM(CASE WHEN o.delivered_late = 1 THEN 1 ELSE 0 END) / COUNT(*) * 100, 1) AS pct_late
FROM olist.orders o
WHERE o.order_delivered_customer_date IS NOT NULL
GROUP BY order_month
ORDER BY order_month;

#--- Top product categories by revenue
SELECT
    p.product_category_name_english AS category,
    COUNT(DISTINCT oi.order_id) AS num_orders,
    ROUND(SUM(oi.price), 2) AS total_revenue
FROM olist.order_items oi
JOIN olist.products p ON oi.product_id = p.product_id
GROUP BY category
ORDER BY total_revenue DESC
LIMIT 15;

#--- Review score drivers (does delivery time affect ratings?)
SELECT
    r.review_score,
    ROUND(AVG(o.delivery_days), 1) AS avg_delivery_days,
    COUNT(*) AS num_reviews
FROM olist.reviews r
JOIN olist.orders o ON r.order_id = o.order_id
WHERE o.delivery_days IS NOT NULL
GROUP BY r.review_score
ORDER BY r.review_score;

#--- Geographic distribution (customer state revenue)
SELECT
    c.customer_state,
    COUNT(DISTINCT o.order_id) AS num_orders,
    ROUND(SUM(ov.order_total), 2) AS total_revenue
FROM olist.orders o
JOIN olist.customers c ON o.customer_id = c.customer_id
JOIN olist.order_value ov ON o.order_id = ov.order_id
GROUP BY c.customer_state
ORDER BY total_revenue DESC;

#--- Monthly revenue trend
SELECT
    DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS order_month,
    ROUND(SUM(ov.order_total), 2) AS total_revenue,
    COUNT(DISTINCT o.order_id) AS num_orders
FROM olist.orders o
JOIN olist.order_value ov ON o.order_id = ov.order_id
GROUP BY order_month
ORDER BY order_month;
