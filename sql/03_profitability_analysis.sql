/*
===========================================================
E-COMMERCE BUSINESS ANALYTICS
03 - PROFITABILITY & DISCOUNT ANALYSIS
===========================================================

Purpose:
Analyze category and product profitability, understand
margin performance, and investigate the relationship
between discount levels and loss-making transactions.

Scope:
Only completed orders are included.
*/


-- =========================================================
-- 1. CATEGORY PROFITABILITY
-- =========================================================

SELECT
    p.category,

    SUM(oi.quantity) AS units_sold,

    ROUND(
        SUM(oi.revenue)::numeric,
        2
    ) AS revenue,

    ROUND(
        SUM(oi.total_cost)::numeric,
        2
    ) AS total_cost,

    ROUND(
        SUM(oi.profit)::numeric,
        2
    ) AS gross_profit,

    ROUND(
        (
            100.0 * SUM(oi.profit) /
            NULLIF(SUM(oi.revenue), 0)
        )::numeric,
        2
    ) AS gross_margin_pct

FROM orders o

JOIN order_items oi
    ON o.order_id = oi.order_id

JOIN products p
    ON oi.product_id = p.product_id

WHERE o.order_status = 'Completed'

GROUP BY
    p.category

ORDER BY
    revenue DESC;


/*
Key project finding:

Electronics generated the highest revenue (~12.79M)
and the highest absolute gross profit (~2.32M),
but had the lowest category gross margin (~18.12%).

Beauty had the highest gross margin (~50.66%).

This demonstrates why revenue and profitability
should be evaluated together.
*/


-- =========================================================
-- 2. PRODUCT-LEVEL PROFITABILITY
-- =========================================================

SELECT
    p.product_id,
    p.product_name,
    p.category,

    SUM(oi.quantity) AS units_sold,

    ROUND(
        SUM(oi.revenue)::numeric,
        2
    ) AS revenue,

    ROUND(
        SUM(oi.profit)::numeric,
        2
    ) AS gross_profit,

    ROUND(
        (
            100.0 * SUM(oi.profit) /
            NULLIF(SUM(oi.revenue), 0)
        )::numeric,
        2
    ) AS gross_margin_pct

FROM orders o

JOIN order_items oi
    ON o.order_id = oi.order_id

JOIN products p
    ON oi.product_id = p.product_id

WHERE o.order_status = 'Completed'

GROUP BY
    p.product_id,
    p.product_name,
    p.category

ORDER BY
    revenue DESC;


/*
This query helps identify products that generate
significant revenue but may have relatively weak margins.
*/


-- =========================================================
-- 3. HIGH-REVENUE, LOW-MARGIN PRODUCTS
-- =========================================================

WITH product_profitability AS (

    SELECT
        p.product_id,
        p.product_name,
        p.category,

        SUM(oi.quantity) AS units_sold,

        SUM(oi.revenue) AS revenue,

        SUM(oi.profit) AS gross_profit,

        (
            100.0 * SUM(oi.profit) /
            NULLIF(SUM(oi.revenue), 0)
        ) AS gross_margin_pct

    FROM orders o

    JOIN order_items oi
        ON o.order_id = oi.order_id

    JOIN products p
        ON oi.product_id = p.product_id

    WHERE o.order_status = 'Completed'

    GROUP BY
        p.product_id,
        p.product_name,
        p.category
)

SELECT
    product_id,
    product_name,
    category,
    units_sold,

    ROUND(
        revenue::numeric,
        2
    ) AS revenue,

    ROUND(
        gross_profit::numeric,
        2
    ) AS gross_profit,

    ROUND(
        gross_margin_pct::numeric,
        2
    ) AS gross_margin_pct

FROM product_profitability

WHERE revenue >= 10000
  AND gross_margin_pct < 15

ORDER BY
    revenue DESC;


/*
Portfolio screening rule:

Revenue >= 10,000
AND
Gross Margin < 15%

The project identified 81 products meeting
these conditions.
*/


-- =========================================================
-- 4. DISCOUNT BAND ANALYSIS
-- =========================================================

WITH discount_analysis AS (

    SELECT
        oi.revenue,
        oi.profit,
        oi.discount_pct,

        CASE

            WHEN oi.discount_pct = 0
                THEN '0%'

            WHEN oi.discount_pct <= 0.05
                THEN '1-5%'

            WHEN oi.discount_pct <= 0.10
                THEN '6-10%'

            WHEN oi.discount_pct <= 0.20
                THEN '11-20%'

            WHEN oi.discount_pct <= 0.30
                THEN '21-30%'

            ELSE 'Other'

        END AS discount_band,

        CASE

            WHEN oi.discount_pct = 0 THEN 1
            WHEN oi.discount_pct <= 0.05 THEN 2
            WHEN oi.discount_pct <= 0.10 THEN 3
            WHEN oi.discount_pct <= 0.20 THEN 4
            WHEN oi.discount_pct <= 0.30 THEN 5

            ELSE 6

        END AS discount_band_sort

    FROM order_items oi

    JOIN orders o
        ON oi.order_id = o.order_id

    WHERE o.order_status = 'Completed'
)

SELECT
    discount_band,

    COUNT(*) AS order_lines,

    ROUND(
        SUM(revenue)::numeric,
        2
    ) AS revenue,

    ROUND(
        SUM(profit)::numeric,
        2
    ) AS gross_profit,

    ROUND(
        (
            100.0 * SUM(profit) /
            NULLIF(SUM(revenue), 0)
        )::numeric,
        2
    ) AS gross_margin_pct,

    COUNT(*) FILTER (
        WHERE profit < 0
    ) AS loss_making_lines

FROM discount_analysis

GROUP BY
    discount_band,
    discount_band_sort

ORDER BY
    discount_band_sort;


/*
Observed pattern:

Discount Band     Gross Margin
--------------------------------
0%                ~28.75%
1-5%              ~26.55%
6-10%             ~21.88%
11-20%            ~14.32%
21-30%            ~26.25%

Margins generally compressed through the 0-20%
discount range.

The 21-30% band should not be interpreted as evidence
that deeper discounts improve profitability because
the result can be affected by product mix and the
smaller number of observations.
*/


-- =========================================================
-- 5. PROFITABLE VS LOSS-MAKING ORDER LINES
-- =========================================================

SELECT

    CASE

        WHEN oi.profit < 0
            THEN 'Loss Making'

        ELSE 'Profitable'

    END AS profitability_status,

    COUNT(*) AS order_lines,

    ROUND(
        (
            100.0 * AVG(oi.discount_pct)
        )::numeric,
        2
    ) AS average_discount_pct,

    ROUND(
        AVG(oi.revenue)::numeric,
        2
    ) AS average_line_revenue,

    ROUND(
        AVG(oi.profit)::numeric,
        2
    ) AS average_line_profit

FROM order_items oi

JOIN orders o
    ON oi.order_id = o.order_id

WHERE o.order_status = 'Completed'

GROUP BY
    profitability_status

ORDER BY
    profitability_status;


/*
Project result:

Loss-Making Lines:
1,113

Average Discount:
Loss-making lines  ~18.31%
Profitable lines   ~5.86%

Average Profit:
Loss-making lines  ~-21.36
Profitable lines   ~56.28

Important:
This establishes an association between discounting
and profitability. It does NOT establish that discounts
alone caused the losses.
*/


-- =========================================================
-- 6. LOSS-MAKING LINES BY DISCOUNT BAND
-- =========================================================

WITH loss_analysis AS (

    SELECT
        oi.profit,

        CASE

            WHEN oi.discount_pct = 0
                THEN '0%'

            WHEN oi.discount_pct <= 0.05
                THEN '1-5%'

            WHEN oi.discount_pct <= 0.10
                THEN '6-10%'

            WHEN oi.discount_pct <= 0.20
                THEN '11-20%'

            WHEN oi.discount_pct <= 0.30
                THEN '21-30%'

            ELSE 'Other'

        END AS discount_band,

        CASE

            WHEN oi.discount_pct = 0 THEN 1
            WHEN oi.discount_pct <= 0.05 THEN 2
            WHEN oi.discount_pct <= 0.10 THEN 3
            WHEN oi.discount_pct <= 0.20 THEN 4
            WHEN oi.discount_pct <= 0.30 THEN 5

            ELSE 6

        END AS discount_band_sort

    FROM order_items oi

    JOIN orders o
        ON oi.order_id = o.order_id

    WHERE o.order_status = 'Completed'
)

SELECT
    discount_band,

    COUNT(*) AS loss_making_lines

FROM loss_analysis

WHERE profit < 0

GROUP BY
    discount_band,
    discount_band_sort

ORDER BY
    discount_band_sort;


/*
The 11-20% discount band contained the large majority
of completed loss-making lines in this dataset.

This should be investigated together with product cost,
category and product mix rather than interpreted as
discount causation.
*/


-- =========================================================
-- 7. OVERALL LOSS-MAKING LINE RATE
-- =========================================================

SELECT

    COUNT(*) AS total_completed_order_lines,

    COUNT(*) FILTER (
        WHERE oi.profit < 0
    ) AS loss_making_lines,

    ROUND(
        (
            100.0 *
            COUNT(*) FILTER (WHERE oi.profit < 0) /
            NULLIF(COUNT(*), 0)
        )::numeric,
        2
    ) AS loss_making_line_pct

FROM order_items oi

JOIN orders o
    ON oi.order_id = o.order_id

WHERE o.order_status = 'Completed';


/*
===========================================================
KEY BUSINESS TAKEAWAYS

1. Revenue alone does not represent product performance.

2. Electronics drives the majority of company revenue,
   but operates at a substantially lower margin than
   several other categories.

3. Margin generally decreases as discounts increase
   through the 0-20% range.

4. Loss-making transactions are disproportionately
   represented in higher discount ranges.

5. Discount strategy should therefore be evaluated
   at product/category level together with cost structure.

6. These results show association, not proof that
   discounting itself caused the losses.

===========================================================
*/