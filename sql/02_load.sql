\set ON_ERROR_STOP on
\encoding UTF8

-- Запускать через psql из корня проекта. CSV полностью заменяют данные в таблицах.
BEGIN;

-- Очищаем связанные таблицы одной командой. RESTRICT защищает другие таблицы.
TRUNCATE TABLE
    public.payments,
    public.order_items,
    public.orders,
    public.customers,
    public.products,
    public.sales_channels,
    public.managers
RESTRICT;

\copy public.managers (manager_id, manager_name) FROM 'data/data_csv/managers.csv' WITH (FORMAT csv, HEADER true, DELIMITER ';', ENCODING 'UTF8')

\copy public.sales_channels (sales_channel_id, sales_channel) FROM 'data/data_csv/sales_channels.csv' WITH (FORMAT csv, HEADER true, DELIMITER ';', ENCODING 'UTF8')

\copy public.products (product_id, product_sku, product_name, product_category, product_brand) FROM 'data/data_csv/product.csv' WITH (FORMAT csv, HEADER true, DELIMITER ';', ENCODING 'UTF8')

-- Временные таблицы принимают текст из CSV перед преобразованием типов.
CREATE TEMP TABLE stg_customers (
    customer_id            text,
    customer_name          text,
    customer_email         text,
    customer_phone         text,
    customer_city          text,
    customer_registered_at text
) ON COMMIT DROP;

\copy pg_temp.stg_customers FROM 'data/data_csv/customers.csv' WITH (FORMAT csv, HEADER true, DELIMITER ';', ENCODING 'UTF8')

INSERT INTO public.customers (
    customer_id, customer_name, customer_email, customer_phone, customer_city,
    customer_registered_at
)
SELECT
    customer_id, customer_name, NULLIF(customer_email, ''), customer_phone, customer_city,
    to_date(customer_registered_at, 'DD.MM.YYYY')
FROM pg_temp.stg_customers;

CREATE TEMP TABLE stg_orders (
    order_date       text,
    order_id         text,
    order_status     text,
    customer_id      text,
    manager_id       text,
    store_id         text,
    sales_channel_id text,
    payment_status   text,
    goods_gross_rub  text,
    discount_rub     text,
    shipping_rub     text,
    order_total_rub  text,
    paid_rub         text,
    refunded_rub     text,
    currency         text,
    delivery_method  text,
    delivery_city    text,
    shipped_at       text,
    delivered_at     text,
    promo_code       text,
    source_system    text,
    updated_at       text
) ON COMMIT DROP;

\copy pg_temp.stg_orders FROM 'data/data_csv/orders.csv' WITH (FORMAT csv, HEADER true, DELIMITER ';', ENCODING 'UTF8')

INSERT INTO public.orders (
    order_date, order_id, order_status, customer_id, manager_id, store_id,
    sales_channel_id, payment_status, goods_gross_rub, discount_rub, shipping_rub,
    order_total_rub, paid_rub, refunded_rub, currency, delivery_method, delivery_city,
    shipped_at, delivered_at, promo_code, source_system, updated_at
)
SELECT
    to_date(order_date, 'DD.MM.YYYY'),
    order_id,
    order_status,
    customer_id,
    NULLIF(manager_id, ''),
    store_id,
    sales_channel_id,
    payment_status,
    replace(goods_gross_rub, ',', '.')::numeric,
    replace(discount_rub, ',', '.')::numeric,
    replace(shipping_rub, ',', '.')::numeric,
    replace(order_total_rub, ',', '.')::numeric,
    replace(paid_rub, ',', '.')::numeric,
    replace(refunded_rub, ',', '.')::numeric,
    currency,
    delivery_method,
    delivery_city,
    to_date(NULLIF(shipped_at, ''), 'DD.MM.YYYY'),
    to_date(NULLIF(delivered_at, ''), 'DD.MM.YYYY'),
    NULLIF(promo_code, ''),
    source_system,
    to_date(updated_at, 'DD.MM.YYYY')
FROM pg_temp.stg_orders;

\copy public.order_items (order_id, line_no, product_id, product_sku, quantity, unit_price_rub, unit_cost_rub, item_discount_pct) FROM 'data/data_csv/order_items.csv' WITH (FORMAT csv, HEADER true, DELIMITER ';', ENCODING 'UTF8')

CREATE TEMP TABLE stg_payments (
    order_id           text,
    payment_id         text,
    payment_method     text,
    payment_date       text,
    payment_amount_rub text
) ON COMMIT DROP;

\copy pg_temp.stg_payments FROM 'data/data_csv/payments.csv' WITH (FORMAT csv, HEADER true, DELIMITER ';', ENCODING 'UTF8')

INSERT INTO public.payments (
    order_id, payment_id, payment_method, payment_date, payment_amount_rub
)
SELECT
    order_id,
    payment_id,
    payment_method,
    to_date(payment_date, 'DD.MM.YYYY'),
    replace(payment_amount_rub, ',', '.')::numeric
FROM pg_temp.stg_payments;

COMMIT;
