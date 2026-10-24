/* =====================================================================
   06 – Dollar impact (supports the recommendation)
   These are estimates. They assume order volume stays at the level
   of the last 12 full months (Mar 2014 – Feb 2015).
   ===================================================================== */


-- 6a. Extra profit from the expansion in the Mini Bear period
-- = actual profit minus what the same orders would have earned at $30.50 (Mr. Fuzzy only)
SELECT
    COUNT(*)                                      AS orders,
    ROUND(SUM(profit_usd), 0)                     AS actual_profit,
    ROUND(COUNT(*) * 30.50, 0)                    AS profit_at_30_50,
    ROUND(SUM(profit_usd) - COUNT(*) * 30.50, 0)  AS extra_profit,
    ROUND(SUM(addon_profit_usd), 0)               AS extra_from_add_ons
FROM order_summary
WHERE period = '5. + Mini Bear';


-- 6b. Scenario: a new add-on that 5% more orders buy, with $20.50 profit each (like the Mini Bear)
SELECT
    COUNT(*)                      AS orders_last_12_months,
    ROUND(COUNT(*) * 0.05)        AS extra_add_ons,
    ROUND(COUNT(*) * 0.05 * 20.50) AS extra_profit_per_year
FROM order_summary
WHERE created_at >= '2014-03-01' AND created_at < '2015-03-01';


-- 6c. Cost of the Mr. Fuzzy refund spike (Aug–Sep 2014)
-- Mr. Fuzzy's normal refund rate in other months is about 4.4% (from 05_refunds.sql).
-- Each extra refund costs $49.99 (profit goes from +$30.50 to −$19.49).
SELECT
    COUNT(*)                                       AS units_sold,
    SUM(is_refunded)                               AS refunds,
    ROUND(COUNT(*) * 0.044)                        AS refunds_expected_at_normal_rate,
    SUM(is_refunded) - ROUND(COUNT(*) * 0.044)     AS extra_refunds,
    ROUND((SUM(is_refunded) - ROUND(COUNT(*) * 0.044)) * 49.99) AS cost_usd
FROM item_summary
WHERE product_short_name = 'Mr. Fuzzy'
  AND created_at >= '2014-08-01' AND created_at < '2014-10-01';


/* Main findings – Dollar impact
   - The expansion added about $210k profit in the Mini Bear period ($189k from add-ons).
   - A new add-on bought by 5% more orders ≈ +$19.5k profit per year.
   - The Mr. Fuzzy refund spike cost about $9k. */


/* OVERALL SUMMARY
   - Expanding to 4 products raised profit per order by 32%, mainly through add-ons.
   - Little cannibalisation: Mr. Fuzzy sales held steady.
   - Recommendation: launch another low-priced add-on, and fix Sugar Panda / Mr. Fuzzy quality.
   - Caveat: website tests ran at the same time, so results are "associated with", not proven causes. 
   
   "Website tests (landing and billing pages) ran during the same period, so results are described as associated 
   with the product launches rather than caused by them. The profit-per-order findings are less affected,
    because those tests mainly influence conversion, not which products customers buy."*/
