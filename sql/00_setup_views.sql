/* =====================================================================
   00 – Setup views 
   A view is a saved query. These 3 views add the columns we need
   (period, product name, add-on profit, ...) so the analysis files stay simple.
   ===================================================================== */


-- Remove old versions of the views (safe to re-run)
DROP VIEW IF EXISTS order_summary;
DROP VIEW IF EXISTS launch_periods;
DROP VIEW IF EXISTS session_summary;
DROP VIEW IF EXISTS item_summary;


-- 0a. session_summary: one row per website session, with its period
-- Periods start at each launch. Cross-selling at the cart started on 25 Sep 2013,
-- so it gets its own period (otherwise its effect would be credited to a product launch).
CREATE VIEW session_summary AS
SELECT
    website_session_id,
    created_at,
    DATE_TRUNC('month', created_at)::date AS session_month,
    CASE
        WHEN created_at < '2013-01-06 13:00' THEN '1. Mr. Fuzzy only'   -- Mr. Fuzzy only
        WHEN created_at < '2013-09-25'       THEN '2. + Love Bear'      -- Love Bear launch
        WHEN created_at < '2013-12-12 09:00' THEN '3. + Cross-sell'     -- Cross-sell started
        WHEN created_at < '2014-02-05 10:00' THEN '4. + Sugar Panda'    -- Sugar Panda launch   
        ELSE                                      '5. + Mini Bear'      -- Mini Bear launch
    END AS period
FROM website_sessions;


-- 0b. item_summary: one row per product sold, with product name and period
CREATE VIEW item_summary AS
SELECT
    oi.order_item_id,
    oi.order_id,
    oi.created_at,
    DATE_TRUNC('month', oi.created_at)::date AS order_month,
    CASE
        WHEN oi.created_at < '2013-01-06 13:00' THEN '1. Mr. Fuzzy only'
        WHEN oi.created_at < '2013-09-25'       THEN '2. + Love Bear'
        WHEN oi.created_at < '2013-12-12 09:00' THEN '3. + Cross-sell'
        WHEN oi.created_at < '2014-02-05 10:00' THEN '4. + Sugar Panda'
        ELSE                                         '5. + Mini Bear'
    END AS period,
    oi.product_id,
    p.product_short_name,
    oi.is_primary_item,
    oi.price_usd::numeric          AS price_usd,
    oi.profit_usd::numeric         AS profit_usd,
    oi.is_refunded,
    oi.refund_amount_usd::numeric  AS refund_amount_usd,
    oi.net_profit_usd::numeric     AS net_profit_usd,
    -- refunds arrive up to 16 days after the order, so orders after 3 Mar 2015 may still be refunded
    CASE WHEN oi.created_at < '2015-03-03' THEN 1 ELSE 0 END AS refund_window_complete
FROM order_items oi
JOIN products p ON p.product_id = oi.product_id;


-- 0c. order_summary: one row per order, with main-item profit and add-on profit
CREATE VIEW order_summary AS
SELECT
    order_id,
    MIN(created_at)                                                      AS created_at,
    MIN(order_month)                                                     AS order_month,
    DATE_TRUNC('quarter', MIN(created_at))::date                         AS order_quarter,
    MIN(period)                                                          AS period,
    MAX(CASE WHEN is_primary_item = 1 THEN product_short_name END)       AS main_product,
    MAX(CASE WHEN is_primary_item = 0 THEN product_short_name END)       AS addon_product,
    COUNT(*)                                                             AS items,
    SUM(price_usd)                                                       AS price_usd,
    SUM(profit_usd)                                                      AS profit_usd,
    SUM(CASE WHEN is_primary_item = 1 THEN profit_usd ELSE 0 END)        AS main_profit_usd,
    SUM(CASE WHEN is_primary_item = 0 THEN profit_usd ELSE 0 END)        AS addon_profit_usd,
    SUM(refund_amount_usd)                                               AS refund_amount_usd,
    SUM(net_profit_usd)                                                  AS net_profit_usd,
    MIN(refund_window_complete)                                          AS refund_window_complete
FROM item_summary
GROUP BY order_id;


-- 0d. Check: the views should have the same number of rows as the tables
SELECT
    (SELECT COUNT(*) FROM session_summary) AS sessions,   -- 472,871
    (SELECT COUNT(*) FROM order_summary)   AS orders,     -- 32,313
    (SELECT COUNT(*) FROM item_summary)    AS items;      -- 40,025



-- First 5 rows of each view, to check the columns and data types
SELECT * FROM session_summary LIMIT 5;
SELECT * FROM order_summary   LIMIT 5;
SELECT * FROM item_summary    LIMIT 5;
