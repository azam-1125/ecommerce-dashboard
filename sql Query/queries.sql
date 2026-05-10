-- ================================================
-- E-commerce Sales Dashboard — SQL Queries
-- Database: MySQL | Dataset: Olist E-commerce
-- ================================================

USE ecommerce;

-- ── Query 1: Monthly Revenue Trend ──────────────
SELECT 
    DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS month,
    COUNT(DISTINCT o.order_id)                        AS total_orders,
    ROUND(SUM(oi.price + oi.freight_value), 2)        AS total_revenue,
    ROUND(AVG(oi.price + oi.freight_value), 2)        AS avg_order_value
FROM olist_orders_dataset o
JOIN olist_order_items_dataset oi ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
GROUP BY month
ORDER BY month;

-- ── Query 2: Revenue by Product Category ────────
SELECT 
    p.product_category_name                           AS category,
    COUNT(DISTINCT o.order_id)                        AS total_orders,
    ROUND(SUM(oi.price), 2)                           AS total_revenue,
    ROUND(AVG(oi.price), 2)                           AS avg_price
FROM olist_orders_dataset o
JOIN olist_order_items_dataset oi ON o.order_id = oi.order_id
JOIN olist_products_dataset p     ON oi.product_id = p.product_id
WHERE o.order_status = 'delivered'
  AND p.product_category_name IS NOT NULL
GROUP BY category
ORDER BY total_revenue DESC
LIMIT 15;

-- ── Query 3: Customer Distribution by State ─────
SELECT 
    c.customer_state                                  AS state,
    COUNT(DISTINCT c.customer_id)                     AS total_customers,
    ROUND(SUM(oi.price + oi.freight_value), 2)        AS total_revenue
FROM olist_customers_dataset c
JOIN olist_orders_dataset o       ON c.customer_id = o.customer_id
JOIN olist_order_items_dataset oi ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
GROUP BY state
ORDER BY total_customers DESC;

-- ── Query 4: Delivery Performance by State ──────
SELECT 
    c.customer_state                                   AS state,
    COUNT(o.order_id)                                  AS total_orders,
    ROUND(AVG(DATEDIFF(
        o.order_delivered_customer_date,
        o.order_purchase_timestamp)), 1)               AS avg_delivery_days,
    ROUND(AVG(DATEDIFF(
        o.order_estimated_delivery_date,
        o.order_delivered_customer_date)), 1)          AS avg_days_early_late,
    SUM(CASE WHEN o.order_delivered_customer_date 
             > o.order_estimated_delivery_date 
             THEN 1 ELSE 0 END)                        AS late_deliveries,
    ROUND(SUM(CASE WHEN o.order_delivered_customer_date 
                   > o.order_estimated_delivery_date 
                   THEN 1 ELSE 0 END) * 100.0 
          / COUNT(o.order_id), 1)                      AS late_delivery_pct
FROM olist_orders_dataset o
JOIN olist_customers_dataset c ON o.customer_id = c.customer_id
WHERE o.order_delivered_customer_date IS NOT NULL
  AND o.order_estimated_delivery_date IS NOT NULL
GROUP BY state
ORDER BY late_delivery_pct DESC;

-- ── Query 5: Payment Method Breakdown ───────────
SELECT 
    payment_type,
    COUNT(DISTINCT order_id)            AS total_orders,
    ROUND(SUM(payment_value), 2)        AS total_value,
    ROUND(AVG(payment_value), 2)        AS avg_value,
    ROUND(COUNT(DISTINCT order_id) * 100.0 
          / SUM(COUNT(DISTINCT order_id)) OVER(), 1) AS pct_of_orders
FROM olist_order_payments_dataset
GROUP BY payment_type
ORDER BY total_orders DESC;

-- ── Query 6: Review Score Distribution ──────────
SELECT 
    r.review_score,
    COUNT(r.review_id)                              AS total_reviews,
    ROUND(COUNT(r.review_id) * 100.0 
          / SUM(COUNT(r.review_id)) OVER(), 1)      AS pct_of_reviews,
    ROUND(AVG(oi.price + oi.freight_value), 2)      AS avg_order_value
FROM olist_order_reviews_dataset r
JOIN olist_orders_dataset o       ON r.order_id = o.order_id
JOIN olist_order_items_dataset oi ON o.order_id = oi.order_id
GROUP BY r.review_score
ORDER BY r.review_score DESC;

-- ── Query 7: RFM Customer Segmentation ──────────
WITH rfm_base AS (
    SELECT 
        c.customer_unique_id,
        MAX(o.order_purchase_timestamp)             AS last_purchase,
        COUNT(DISTINCT o.order_id)                  AS frequency,
        ROUND(SUM(oi.price + oi.freight_value), 2)  AS monetary
    FROM olist_customers_dataset c
    JOIN olist_orders_dataset o       ON c.customer_id = o.customer_id
    JOIN olist_order_items_dataset oi ON o.order_id = oi.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_unique_id
),
rfm_scored AS (
    SELECT *,
        DATEDIFF('2018-10-01', last_purchase)       AS recency_days,
        NTILE(5) OVER (ORDER BY DATEDIFF('2018-10-01', last_purchase) ASC) AS r_score,
        NTILE(5) OVER (ORDER BY frequency DESC)     AS f_score,
        NTILE(5) OVER (ORDER BY monetary DESC)      AS m_score
    FROM rfm_base
)
SELECT 
    customer_unique_id,
    recency_days,
    frequency,
    monetary,
    r_score, f_score, m_score,
    (r_score + f_score + m_score)                   AS rfm_total,
    CASE 
        WHEN (r_score + f_score + m_score) >= 13 THEN 'Champions'
        WHEN (r_score + f_score + m_score) >= 10 THEN 'Loyal Customers'
        WHEN (r_score + f_score + m_score) >= 7  THEN 'Potential Loyalists'
        WHEN (r_score + f_score + m_score) >= 5  THEN 'At Risk'
        ELSE 'Lost Customers'
    END                                             AS customer_segment
FROM rfm_scored
ORDER BY rfm_total DESC;