/* =====================================================================
   02 – Profit drivers
   Question : Where did the extra profit per order come from?
              (a) customers choosing different main products (product mix), or
              (b) customers adding a second item (cross-sell)?
   Idea     : profit per order = main-item profit + add-on profit.
              Prices never changed, so these two parts explain all of the change.
   ===================================================================== */


-- 2a. Price, cost and margin of each product
SELECT
    product_short_name,
    MAX(price_usd)                                  AS price_usd,
    MAX(profit_usd)                                 AS profit_per_unit,
    ROUND(100 * MAX(profit_usd) / MAX(price_usd), 1) AS margin_pct
FROM item_summary
GROUP BY product_id, product_short_name
ORDER BY product_id;


-- 2b. Profit per order split into main item and add-on, by period
-- Compare with period 1 ($30.50, no add-ons):
--   change in main_item_profit = effect of product mix
--   add_on_profit              = effect of cross-sell
SELECT
    period,
    COUNT(*)                          AS orders,
    ROUND(AVG(profit_usd), 2)         AS profit_per_order,
    ROUND(AVG(main_profit_usd), 2)    AS main_item_profit,
    ROUND(AVG(addon_profit_usd), 2)   AS add_on_profit
FROM order_summary
GROUP BY period
ORDER BY period;


-- 2c. Which main product do customers choose? (% of orders, by period)
-- when customers buy, which bear do they pick as their main item
SELECT
    period,
    COUNT(*) AS orders,
    ROUND(100.0 * SUM(CASE WHEN main_product = 'Mr. Fuzzy'   THEN 1 ELSE 0 END) / COUNT(*), 1) AS mr_fuzzy_pct,
    ROUND(100.0 * SUM(CASE WHEN main_product = 'Love Bear'   THEN 1 ELSE 0 END) / COUNT(*), 1) AS love_bear_pct,
    ROUND(100.0 * SUM(CASE WHEN main_product = 'Sugar Panda' THEN 1 ELSE 0 END) / COUNT(*), 1) AS sugar_panda_pct,
    ROUND(100.0 * SUM(CASE WHEN main_product = 'Mini Bear'   THEN 1 ELSE 0 END) / COUNT(*), 1) AS mini_bear_pct
FROM order_summary
GROUP BY period
ORDER BY period;


-- 2d. Quarterly trend of the split (for a Power BI line chart)
SELECT
    order_quarter,
    ROUND(AVG(profit_usd), 2)         AS profit_per_order,
    ROUND(AVG(main_profit_usd), 2)    AS main_item_profit,
    ROUND(AVG(addon_profit_usd), 2)   AS add_on_profit
FROM order_summary
GROUP BY order_quarter
ORDER BY order_quarter;


/* Main findings – Profit drivers
   - About 90% of the gain came from add-ons (cross-sell), only about 10% from product mix.
   - Main-item profit stayed around $31.50, because prices never changed. */
