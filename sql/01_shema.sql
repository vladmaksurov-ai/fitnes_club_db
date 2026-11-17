BEGIN;

CREATE TABLE public.customers (
                                  customer_id            text PRIMARY KEY,
                                  customer_name          text NOT NULL,
                                  customer_email         text,
                                  customer_phone         text NOT NULL,
                                  customer_city          text NOT NULL,
                                  customer_registered_at date NOT NULL
);

CREATE TABLE public.managers (
                                 manager_id   text PRIMARY KEY,
                                 manager_name text NOT NULL
);

CREATE TABLE public.sales_channels (
                                       sales_channel_id text PRIMARY KEY,
                                       sales_channel    text NOT NULL
);

-- Источник — product.csv
CREATE TABLE public.products (
                                 product_id       text PRIMARY KEY,
                                 product_sku      text NOT NULL UNIQUE,
                                 product_name     text NOT NULL,
                                 product_category text NOT NULL,
                                 product_brand    text NOT NULL
);

CREATE TABLE public.orders (
                               order_date       date NOT NULL,
                               order_id         text PRIMARY KEY,
                               order_status     text NOT NULL,
                               customer_id      text NOT NULL REFERENCES public.customers (customer_id),
                               manager_id       text REFERENCES public.managers (manager_id),
                               store_id         text NOT NULL,
                               sales_channel_id text NOT NULL REFERENCES public.sales_channels (sales_channel_id),
                               payment_status   text NOT NULL,
                               goods_gross_rub  numeric(12, 2) NOT NULL CHECK (goods_gross_rub >= 0),
                               discount_rub     numeric(12, 2) NOT NULL CHECK (discount_rub >= 0),
                               shipping_rub     numeric(12, 2) NOT NULL CHECK (shipping_rub >= 0),
                               order_total_rub  numeric(12, 2) NOT NULL CHECK (order_total_rub >= 0),
                               paid_rub         numeric(12, 2) NOT NULL CHECK (paid_rub >= 0),
                               refunded_rub     numeric(12, 2) NOT NULL CHECK (refunded_rub >= 0),
                               currency         text NOT NULL,
                               delivery_method  text NOT NULL,
                               delivery_city    text NOT NULL,
                               shipped_at       date,
                               delivered_at     date,
                               promo_code       text,
                               source_system    text NOT NULL,
                               updated_at       date NOT NULL
);

CREATE TABLE public.order_items (
                                    order_id          text NOT NULL REFERENCES public.orders (order_id),
                                    line_no           integer NOT NULL CHECK (line_no > 0),
                                    product_id        text NOT NULL REFERENCES public.products (product_id),
                                    product_sku       text NOT NULL,
                                    quantity          integer NOT NULL CHECK (quantity > 0),
                                    unit_price_rub    numeric(12, 2) NOT NULL CHECK (unit_price_rub >= 0),
                                    unit_cost_rub     numeric(12, 2) NOT NULL CHECK (unit_cost_rub >= 0),
                                    item_discount_pct numeric(5, 2) NOT NULL
                                        CHECK (item_discount_pct BETWEEN 0 AND 100),
                                    PRIMARY KEY (order_id, line_no)
);

CREATE TABLE public.payments (
                                 order_id           text NOT NULL REFERENCES public.orders (order_id),
                                 payment_id         text PRIMARY KEY,
                                 payment_method     text NOT NULL,
                                 payment_date       date NOT NULL,
                                 payment_amount_rub numeric(12, 2) NOT NULL CHECK (payment_amount_rub > 0)
);

COMMIT;