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