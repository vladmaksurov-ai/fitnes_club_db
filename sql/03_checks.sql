SELECT 'customers'    AS table,
       COUNT(*)       AS actual_row,
       402            AS expected_rows,
       COUNT(*) = 402 AS passed
FROM customers
UNION ALL
SELECT 'managers'    AS table,
       COUNT(*)       AS actual_row,
       8            AS expected_rows,
       COUNT(*) = 8 AS passed
FROM managers
UNION ALL
SELECT 'order_items'    AS table,
       COUNT(*)       AS actual_row,
       3160            AS expected_rows,
       COUNT(*) = 3160 AS passed
FROM order_items
UNION ALL
SELECT 'orders'    AS table,
       COUNT(*)       AS actual_row,
       1455            AS expected_rows,
       COUNT(*) = 1455 AS passed
FROM orders
UNION ALL
SELECT 'payments'    AS table,
       COUNT(*)       AS actual_row,
       1244            AS expected_rows,
       COUNT(*) = 1244 AS passed
FROM payments
UNION ALL
SELECT 'products'    AS table,
       COUNT(*)       AS actual_row,
       30            AS expected_rows,
       COUNT(*) = 30 AS passed
FROM products
UNION ALL
SELECT 'sales_channels'    AS table,
       COUNT(*)       AS actual_row,
       4            AS expected_rows,
       COUNT(*) = 4 AS passed
FROM sales_channels;

SELECT i.order_id,
       i.line_no,
       i.product_sku AS item_sku,
       p.product_sku AS catalog_sku
FROM order_items AS i
         JOIN products AS p ON p.product_id = i.product_id
WHERE i.product_sku <> p.product_sku;

SELECT o.order_id,
       order_total_rub,
       SUM(i.quantity * i.unit_price_rub * (1 - i.item_discount_pct / 100)) + o.shipping_rub
           AS items_total_rub,
       o.order_total_rub = SUM(i.quantity * i.unit_price_rub * (1 - i.item_discount_pct / 100)) + o.shipping_rub AS passed
FROM orders AS o
         JOIN order_items AS i ON i.order_id = o.order_id
GROUP BY o.order_id;

SELECT o.order_id,
       o.paid_rub,
       COALESCE(SUM(p.payment_amount_rub), 0) AS payment_total_rub,
       ABS(o.paid_rub - COALESCE(SUM(p.payment_amount_rub), 0)) <=0.1 AS passed
FROM orders AS o
         LEFT JOIN payments AS p ON p.order_id = o.order_id
GROUP BY o.order_id

