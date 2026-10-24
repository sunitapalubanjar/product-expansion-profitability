/* =====================================================================
   01 – Launch impact
   Question : Did profit per order and total profit rise after each launch?
   Note     : Traffic grew a lot, so per-order measures matter more than totals.
   ===================================================================== */


-- 1a. Orders and profit by period
SELECT
    period,
    COUNT(*)                     AS orders,
    ROUND(AVG(price_usd), 2)     AS avg_order_value,
    ROUND(AVG(items), 2)         AS items_per_order,
    ROUND(AVG(profit_usd), 2)    AS profit_per_order,
    ROUND(SUM(profit_usd), 0)    AS total_profit
FROM order_summary
GROUP BY period
ORDER BY period;


-- 1b. Conversion rate by period (orders per 100 sessions)
WITH sessions AS (
    SELECT period, COUNT(*) AS sessions
    FROM session_summary
    GROUP BY period
),
orders AS (
    SELECT period, COUNT(*) AS orders
    FROM order_summary
    GROUP BY period
)
SELECT
    s.period,
    s.sessions,
    o.orders,
    ROUND(100.0 * o.orders / s.sessions, 2) AS conversion_pct
FROM sessions s
JOIN orders o ON o.period = s.period
ORDER BY s.period;


-- 1c. Profit per order, 6 weeks before vs 6 weeks after the Mini Bear launch (5 Feb 2014)
-- Change the two dates to check another launch:
--   Love Bear 2013-01-06, Cross-sell 2013-09-25, Sugar Panda 2013-12-12
SELECT
    CASE WHEN created_at < '2014-02-05' THEN '1. before' ELSE '2. after' END AS window_side,
    COUNT(*)                     AS orders,
    ROUND(AVG(profit_usd), 2)    AS profit_per_order,
    ROUND(AVG(items), 2)         AS items_per_order
FROM order_summary
WHERE created_at >= DATE '2014-02-05' - 42
  AND created_at <  DATE '2014-02-05' + 42
GROUP BY window_side
ORDER BY window_side;


-- 1d. Profit per order by quarter (compare the same quarter across years to avoid seasonality)
-- 2012 Q1 and 2015 Q1 are partial quarters.
SELECT
    order_quarter,
    COUNT(*)                     AS orders,
    ROUND(AVG(profit_usd), 2)    AS profit_per_order,
    ROUND(AVG(items), 2)         AS items_per_order,
    ROUND(SUM(profit_usd), 0)    AS total_profit
FROM order_summary
GROUP BY order_quarter
ORDER BY order_quarter;


/* Main findings – Launch impact
   - Profit per order rose after every launch: $30.50 → $40.41 (+32%).
   - Biggest jump with the Mini Bear launch (about +$4.40 per order).
   - Items per order went from 1.00 to 1.35. */
