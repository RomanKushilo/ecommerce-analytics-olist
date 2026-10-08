--Проверка целостности
SELECT COUNT(*) FROM customers;
SELECT COUNT(*) FROM orders;
SELECT COUNT(*) FROM order_items;
SELECT COUNT(*) FROM order_payments;
SELECT COUNT(*) FROM order_reviews;
SELECT COUNT(*) FROM products;
SELECT COUNT(*) FROM sellers;

SELECT *
FROM orders
LIMIT 10;

SELECT *
FROM customers
LIMIT 10;

SELECT *
FROM order_items
LIMIT 10;

SELECT *
FROM order_payments
LIMIT 10;

SELECT *
FROM order_reviews
LIMIT 10;

SELECT *
FROM products
LIMIT 10;

SELECT *
FROM sellers
LIMIT 10;

--Проверка дубликатов
SELECT
    order_id,
    COUNT(*) AS cnt
FROM orders
GROUP BY order_id
HAVING COUNT(*) > 1;

SELECT
    product_id,
    COUNT(*) AS cnt
FROM products
GROUP BY product_id
HAVING COUNT(*) > 1;

SELECT
    seller_id,
    COUNT(*) AS cnt
FROM sellers
GROUP BY seller_id
HAVING COUNT(*) > 1;

--Проверка наличия нескольких покупок у одного покупателя
SELECT
    customer_unique_id,
    COUNT(*) AS customer_records
FROM customers
GROUP BY customer_unique_id
HAVING COUNT(*) > 1
ORDER BY customer_records DESC;

--Проверка NULL
SELECT
    COUNT(*) AS total_rows,
    COUNT(product_category_name) AS category_filled,
    COUNT(product_weight_g) AS weight_filled
FROM products;

SELECT
    COUNT(*) AS total_rows,
    COUNT(order_approved_at) AS approved_rows,
    COUNT(order_delivered_customer_date) AS delivered_rows
FROM orders;

--Проверка корректности чисел
SELECT
    MIN(price) AS min_price,
    MAX(price) AS max_price,
    AVG(price) AS avg_price
FROM order_items;

SELECT
    MIN(freight_value) AS min_freight,
    MAX(freight_value) AS max_freight,
    AVG(freight_value) AS avg_freight
FROM order_items;

SELECT
    MIN(payment_value) AS min_payment,
    MAX(payment_value) AS max_payment,
    AVG(payment_value) AS avg_payment
FROM order_payments;

--Проверка связей между таблицами
SELECT COUNT(*) AS missing_products
FROM order_items oi
LEFT JOIN products p
    ON oi.product_id = p.product_id
WHERE p.product_id IS NULL;

SELECT COUNT(*) AS missing_sellers
FROM order_items oi
LEFT JOIN sellers s
    ON oi.seller_id = s.seller_id
WHERE s.seller_id IS NULL;

SELECT COUNT(*) AS missing_orders
FROM order_items oi
LEFT JOIN orders o
    ON oi.order_id = o.order_id
WHERE o.order_id IS NULL;

--Проверка дат
SELECT
    MIN(order_purchase_timestamp) AS first_order,
    MAX(order_purchase_timestamp) AS last_order
FROM orders;