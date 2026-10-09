--Выручка
SELECT
    SUM(price) AS product_revenue,
    SUM(freight_value) AS freight_revenue,
    SUM(price + freight_value) AS total_order_value
FROM order_items;

--Количество заказов
SELECT
    COUNT(DISTINCT order_id) AS orders
FROM orders;

--Средний чек
SELECT
    SUM(price) / COUNT(DISTINCT order_id) AS avg_order_value
FROM order_items;

-- Динамика продаж по месяцам
WITH monthly_sales AS (
    SELECT
        DATE_TRUNC('month', o.order_purchase_timestamp)::date AS month,
        COUNT(DISTINCT o.order_id) AS orders_count,
        SUM(oi.price) AS product_revenue,
        SUM(oi.freight_value) AS freight_revenue,
        SUM(oi.price + oi.freight_value) AS total_order_value
    FROM orders o
    JOIN order_items oi
        ON o.order_id = oi.order_id
    WHERE o.order_status = 'delivered'
      AND o.order_purchase_timestamp IS NOT NULL
    GROUP BY DATE_TRUNC('month', o.order_purchase_timestamp)::date
)
SELECT
    month,
    orders_count,
    ROUND(product_revenue, 2) AS product_revenue,
    ROUND(freight_revenue, 2) AS freight_revenue,
    ROUND(total_order_value, 2) AS total_order_value,
    ROUND(total_order_value / NULLIF(orders_count, 0), 2) AS avg_order_value
FROM monthly_sales
ORDER BY month;

-- Изменение выручки относительно предыдущего месяца
WITH monthly_sales AS (
    SELECT
        DATE_TRUNC('month', o.order_purchase_timestamp)::date AS month,
        SUM(oi.price) AS product_revenue,
        COUNT(DISTINCT o.order_id) AS orders_count
    FROM orders o
    JOIN order_items oi
        ON o.order_id = oi.order_id
    WHERE o.order_status = 'delivered'
      AND o.order_purchase_timestamp IS NOT NULL
    GROUP BY DATE_TRUNC('month', o.order_purchase_timestamp)::date
),
sales_with_previous AS (
    SELECT
        month,
        product_revenue,
        orders_count,
        LAG(product_revenue) OVER (ORDER BY month) AS previous_revenue,
        LAG(orders_count) OVER (ORDER BY month) AS previous_orders
    FROM monthly_sales
),
SELECT
    month,
    ROUND(product_revenue, 2) AS product_revenue,
    ROUND(previous_revenue, 2) AS previous_revenue,
    ROUND(
        100.0 * (product_revenue - previous_revenue)
        / NULLIF(previous_revenue, 0),
        2
    ) AS revenue_mom_pct,
    orders_count,
    previous_orders,
    ROUND(
        100.0 * (orders_count - previous_orders)
        / NULLIF(previous_orders, 0),
        2
    ) AS orders_mom_pct
FROM sales_with_previous
ORDER BY month;

-- MoM среднего чека
WITH monthly_sales AS (
    SELECT
        DATE_TRUNC('month', o.order_purchase_timestamp)::date AS month,
        COUNT(DISTINCT o.order_id) AS orders_count,
        SUM(oi.price) AS product_revenue
    FROM orders o
    JOIN order_items oi
        ON o.order_id = oi.order_id
    WHERE o.order_status = 'delivered'
      AND o.order_purchase_timestamp IS NOT NULL
    GROUP BY DATE_TRUNC('month', o.order_purchase_timestamp)::date
),
monthly_aov AS (
    SELECT
        month,
        orders_count,
        product_revenue,
        product_revenue / NULLIF(orders_count, 0) AS avg_order_value
    FROM monthly_sales
),
aov_with_previous AS (
    SELECT
        month,
        orders_count,
        avg_order_value,
        LAG(avg_order_value) OVER (ORDER BY month) AS previous_avg_order_value
    FROM monthly_aov
)
SELECT
    month,
    orders_count,
    ROUND(avg_order_value, 2) AS avg_order_value,
    ROUND(previous_avg_order_value, 2) AS previous_avg_order_value,
    ROUND(
        100.0 * (avg_order_value - previous_avg_order_value)
        / NULLIF(previous_avg_order_value, 0),
        2
    ) AS aov_mom_pct
FROM aov_with_previous
ORDER BY month;