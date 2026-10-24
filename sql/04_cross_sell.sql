/* =====================================================================
   04 – Cross-sell patterns
   Question : Which product is added to which? What role does the Mini Bear play?
   Note     : Cross-selling started on 25 Sep 2013, so 4a and 4b only use orders from that date.
   ===================================================================== */


-- 4a. Cross-sell matrix: main product (rows) x add-on product (columns)
SELECT
    main_product,
    COUNT(*)                                                         AS orders,
    SUM(CASE WHEN addon_product = 'Mr. Fuzzy'   THEN 1 ELSE 0 END)   AS with_mr_fuzzy,
    SUM(CASE WHEN addon_product = 'Love Bear'   THEN 1 ELSE 0 END)   AS with_love_bear,
    SUM(CASE WHEN addon_product = 'Sugar Panda' THEN 1 ELSE 0 END)   AS with_sugar_panda,
    SUM(CASE WHEN addon_product = 'Mini Bear'   THEN 1 ELSE 0 END)   AS with_mini_bear,
    ROUND(100.0 * SUM(CASE WHEN items = 2 THEN 1 ELSE 0 END) / COUNT(*), 1) AS attach_rate_pct
FROM order_summary
WHERE created_at >= '2013-09-25'
GROUP BY main_product
ORDER BY orders DESC;


-- 4b. Share of orders with an add-on, by period
SELECT
    period,
    COUNT(*) AS orders,
    ROUND(100.0 * SUM(CASE WHEN items = 2 THEN 1 ELSE 0 END) / COUNT(*), 1)                    AS attach_rate_pct,
    ROUND(100.0 * SUM(CASE WHEN addon_product = 'Mini Bear' THEN 1 ELSE 0 END) / COUNT(*), 1)  AS mini_bear_addon_pct
FROM order_summary
WHERE created_at >= '2013-09-25'
GROUP BY period
ORDER BY period;


-- 4c. Is each product sold as the main item or as an add-on?
SELECT
    product_short_name,
    COUNT(*)                                                                    AS units_sold,
    SUM(CASE WHEN is_primary_item = 0 THEN 1 ELSE 0 END)                        AS as_add_on,
    ROUND(100.0 * SUM(CASE WHEN is_primary_item = 0 THEN 1 ELSE 0 END) / COUNT(*), 1) AS add_on_pct,
    ROUND(SUM(profit_usd), 0)                                                   AS total_profit
FROM item_summary
GROUP BY product_id, product_short_name
ORDER BY product_id;


-- 4d. How much profit came from add-ons since the Mini Bear launch?
SELECT
    COUNT(*)                                                  AS orders,
    ROUND(SUM(profit_usd), 0)                                 AS total_profit,
    ROUND(SUM(addon_profit_usd), 0)                           AS add_on_profit,
    ROUND(100 * SUM(addon_profit_usd) / SUM(profit_usd), 1)   AS add_on_share_pct
FROM order_summary
WHERE period = '5. + Mini Bear';


/* Main findings – Cross-sell
   - Orders with an add-on rose from 4% to 35% after the Mini Bear launch.
   - The Mini Bear is the add-on in about 60% of 2-item orders (88% of its sales are add-ons). */
