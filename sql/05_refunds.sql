/* =====================================================================
   05 – Refunds as a hidden cost
   Question : What is the refund rate by product and over time,
              and how much profit is left after refunds?
   Note     : Orders after 3 Mar 2015 may still be refunded later,
              so refund rates only use refund_window_complete = 1.
   ===================================================================== */


-- 5a. Refund rate and profit after refunds, by product
SELECT
    product_short_name,
    COUNT(*)                                          AS units_sold,
    SUM(is_refunded)                                  AS units_refunded,
    ROUND(100.0 * SUM(is_refunded) / COUNT(*), 1)     AS refund_rate_pct,
    ROUND(SUM(profit_usd), 0)                         AS gross_profit,
    ROUND(SUM(net_profit_usd), 0)                     AS net_profit,
    ROUND(100 * SUM(net_profit_usd) / SUM(price_usd), 1) AS net_margin_pct
FROM item_summary
WHERE refund_window_complete = 1
GROUP BY product_id, product_short_name
ORDER BY product_id;


-- 5b. Monthly refund rate by product (look for spikes = possible quality problem)
SELECT
    order_month,
    product_short_name,
    COUNT(*)                                       AS units_sold,
    ROUND(100.0 * SUM(is_refunded) / COUNT(*), 1)  AS refund_rate_pct
FROM item_summary
WHERE refund_window_complete = 1
GROUP BY order_month, product_short_name
ORDER BY order_month, product_short_name;


-- 5c. Mr. Fuzzy months with a refund rate above 10% (its normal rate is about 5%)
SELECT
    order_month,
    COUNT(*)                                       AS units_sold,
    SUM(is_refunded)                               AS units_refunded,
    ROUND(100.0 * SUM(is_refunded) / COUNT(*), 1)  AS refund_rate_pct
FROM item_summary
WHERE product_short_name = 'Mr. Fuzzy'
  AND refund_window_complete = 1
GROUP BY order_month
HAVING 100.0 * SUM(is_refunded) / COUNT(*) > 10
ORDER BY order_month;


-- 5d. Profit per order before and after refunds, by period
SELECT
    period,
    ROUND(AVG(profit_usd), 2)       AS gross_profit_per_order,
    ROUND(AVG(net_profit_usd), 2)   AS net_profit_per_order
FROM order_summary
WHERE refund_window_complete = 1
GROUP BY period
ORDER BY period;


/* Main findings – Refunds
   - Sugar Panda (6%) and Mr. Fuzzy (5%) have the highest refund rates, Mini Bear the lowest (1%).
   - Mr. Fuzzy refunds spiked to about 13–14% in Aug–Sep 2014 → likely a quality problem. */
