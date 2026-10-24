/* =====================================================================
   03 – Cannibalisation
   Question : When a new product launched, did Mr. Fuzzy sales drop,
              or were the new products' sales extra?
   Idea     : Traffic grew, so order counts always rise. Compare orders PER 100 SESSIONS:
              - Mr. Fuzzy rate falls       → buyers switched (cannibalisation)
              - Mr. Fuzzy rate stays level → new sales were extra
   ===================================================================== */


-- 3a. Orders per 100 sessions, Mr. Fuzzy vs the new products, by period
WITH sessions AS (
    SELECT period, COUNT(*) AS sessions
    FROM session_summary
    GROUP BY period
),
orders AS (
    SELECT
        period,
        SUM(CASE WHEN main_product = 'Mr. Fuzzy'  THEN 1 ELSE 0 END) AS mr_fuzzy_orders,
        SUM(CASE WHEN main_product <> 'Mr. Fuzzy' THEN 1 ELSE 0 END) AS new_product_orders
    FROM order_summary
    GROUP BY period
)
SELECT
    s.period,
    s.sessions,
    ROUND(100.0 * o.mr_fuzzy_orders    / s.sessions, 2) AS mr_fuzzy_per_100_sessions,
    ROUND(100.0 * o.new_product_orders / s.sessions, 2) AS new_products_per_100_sessions
FROM sessions s
JOIN orders o ON o.period = s.period
ORDER BY s.period;


-- 3b. The same by month (for a Power BI trend chart)
-- Look at February: Love Bear peaks every year (Valentine's Day) and Mr. Fuzzy dips.
WITH sessions AS (
    SELECT session_month, COUNT(*) AS sessions
    FROM session_summary
    GROUP BY session_month
),
orders AS (
    SELECT
        order_month,
        SUM(CASE WHEN main_product = 'Mr. Fuzzy'   THEN 1 ELSE 0 END) AS mr_fuzzy,
        SUM(CASE WHEN main_product = 'Love Bear'   THEN 1 ELSE 0 END) AS love_bear,
        SUM(CASE WHEN main_product = 'Sugar Panda' THEN 1 ELSE 0 END) AS sugar_panda
    FROM order_summary
    GROUP BY order_month
)
SELECT
    s.session_month,
    ROUND(100.0 * o.mr_fuzzy    / s.sessions, 2) AS mr_fuzzy_per_100_sessions,
    ROUND(100.0 * o.love_bear   / s.sessions, 2) AS love_bear_per_100_sessions,
    ROUND(100.0 * o.sugar_panda / s.sessions, 2) AS sugar_panda_per_100_sessions
FROM sessions s
JOIN orders o ON o.order_month = s.session_month
ORDER BY s.session_month;


-- 3c. Which product page do visitors open? (% of product page views, by period)
SELECT
    s.period,
    COUNT(*) AS product_page_views,
    ROUND(100.0 * SUM(CASE WHEN pv.pageview_url = '/the-original-mr-fuzzy'      THEN 1 ELSE 0 END) / COUNT(*), 1) AS mr_fuzzy_pct,
    ROUND(100.0 * SUM(CASE WHEN pv.pageview_url = '/the-forever-love-bear'      THEN 1 ELSE 0 END) / COUNT(*), 1) AS love_bear_pct,
    ROUND(100.0 * SUM(CASE WHEN pv.pageview_url = '/the-birthday-sugar-panda'   THEN 1 ELSE 0 END) / COUNT(*), 1) AS sugar_panda_pct,
    ROUND(100.0 * SUM(CASE WHEN pv.pageview_url = '/the-hudson-river-mini-bear' THEN 1 ELSE 0 END) / COUNT(*), 1) AS mini_bear_pct
FROM website_pageviews pv
JOIN session_summary s ON s.website_session_id = pv.website_session_id
WHERE pv.pageview_url IN ('/the-original-mr-fuzzy', '/the-forever-love-bear',
                          '/the-birthday-sugar-panda', '/the-hudson-river-mini-bear')
GROUP BY s.period
ORDER BY s.period;


/* Main findings – Cannibalisation
   - Mr. Fuzzy kept selling about 5 orders per 100 sessions, so new sales were mostly extra.
   - February dips in Mr. Fuzzy = Valentine's Day (Love Bear peak), not cannibalisation. */
