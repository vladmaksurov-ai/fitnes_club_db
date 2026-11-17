SELECT
    date_trunc('month' ,order_date)::date AS order_month,
    SUM(paid_rub) / 1000 AS paid_thousand_rub,
    SUM(refunded_rub) / 1000 AS refunded_thousand_rub,
    SUM(paid_rub - refunded_rub) / 1000 AS net_paid_thousand_rub
FROM orders
GROUP BY date_trunc('month' ,order_date)
ORDER BY order_month;

SELECT
    sc.sales_channel_id,
    sc.sales_channel,
    COUNT(*) AS total_order_count,
    COUNT(*) FILTER ( WHERE refunded_rub <> 0 ) refunded_count,
    ROUND((COUNT(*) FILTER ( WHERE refunded_rub <> 0 ) * 1.0 / COUNT(*)) * 100, 2) AS refunded_order_pct,
    SUM(o.paid_rub - o.refunded_rub) / 1000 AS net_paid_thousand_rub
FROM orders AS o
JOIN sales_channels AS sc
    ON o.sales_channel_id = sc.sales_channel_id
GROUP BY sc.sales_channel_id, sc.sales_channel
ORDER BY total_order_count DESC;

SELECT
    p.product_id,
    p.product_name,
    (SUM(unit_price_rub * quantity * (1-(item_discount_pct/100)))) / 1000 AS sales_rub_thd,
    (SUM(unit_price_rub * quantity * (1-(item_discount_pct/100))) - SUM(unit_cost_rub * quantity)) / 1000 AS gross_profit_rub_thd
FROM orders AS o
JOIN order_items AS oi
    ON o.order_id = oi.order_id
JOIN products AS p
    ON oi.product_id = p.product_id
GROUP BY p.product_id, p.product_name
ORDER BY gross_profit_rub_thd DESC