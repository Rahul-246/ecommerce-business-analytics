/*
===========================================================
E-COMMERCE BUSINESS ANALYTICS
06 - RETURNS & REFUND ANALYSIS
===========================================================

Purpose:
Analyze realized refunds, return rates, return reasons,
category-level return risk and high-return products.

Scope:
Official return KPIs use only records where:
return_status = 'Refunded'

This prevents Approved and Processing returns from
being treated as completed financial refunds.
*/


-- =========================================================
-- 1. RETURN STATUS DISTRIBUTION
-- =========================================================

SELECT
    return_status,

    COUNT(*) AS return_records,

    COUNT(DISTINCT order_id) AS orders,

    SUM(returned_quantity) AS returned_units,

    ROUND(
        SUM(refund_amount)::numeric,
        2
    ) AS refund_amount

FROM returns

GROUP BY
    return_status

ORDER BY
    refund_amount DESC;


/*
Project results:

Refunded:
4,442 records
4,264 orders
5,366 units
862,639.96 refund amount

Approved and Processing records are excluded from
official realized-refund KPIs.
*/


-- =========================================================
-- 2. OVERALL RETURN & REFUND KPIs
-- =========================================================

WITH sales_summary AS (

    SELECT
        COUNT(DISTINCT o.order_id)
            AS completed_orders,

        SUM(oi.quantity)
            AS units_sold,

        SUM(oi.revenue)
            AS revenue

    FROM orders o

    JOIN order_items oi
        ON o.order_id = oi.order_id

    WHERE
        o.order_status = 'Completed'
),

refund_summary AS (

    SELECT
        COUNT(DISTINCT order_id)
            AS orders_with_refunds,

        SUM(returned_quantity)
            AS refunded_units,

        SUM(refund_amount)
            AS refund_amount

    FROM returns

    WHERE
        return_status = 'Refunded'
)

SELECT
    s.completed_orders,

    r.orders_with_refunds,

    s.units_sold,

    r.refunded_units,

    ROUND(
        r.refund_amount::numeric,
        2
    ) AS refund_amount,

    ROUND(
        (
            100.0 * r.refunded_units /
            NULLIF(s.units_sold, 0)
        )::numeric,
        2
    ) AS unit_return_rate_pct,

    ROUND(
        (
            100.0 * r.orders_with_refunds /
            NULLIF(s.completed_orders, 0)
        )::numeric,
        2
    ) AS order_return_rate_pct,

    ROUND(
        (
            100.0 * r.refund_amount /
            NULLIF(s.revenue, 0)
        )::numeric,
        2
    ) AS refund_to_revenue_pct

FROM sales_summary s

CROSS JOIN refund_summary r;


/*
Official project KPIs:

Completed Orders       : 43,001
Orders With Refunds    : 4,264

Units Sold             : 123,654
Refunded Units         : 5,366

Refund Amount          : 862,639.96

Unit Return Rate       : 4.34%
Order Return Rate      : 9.92%
Refund-to-Revenue      : 4.40%
*/


-- =========================================================
-- 3. NET REVENUE AFTER REFUNDS
-- =========================================================

WITH sales AS (

    SELECT
        SUM(oi.revenue) AS revenue

    FROM orders o

    JOIN order_items oi
        ON o.order_id = oi.order_id

    WHERE
        o.order_status = 'Completed'
),

refunds AS (

    SELECT
        SUM(refund_amount) AS refund_amount

    FROM returns

    WHERE
        return_status = 'Refunded'
)

SELECT

    ROUND(
        s.revenue::numeric,
        2
    ) AS gross_revenue,

    ROUND(
        r.refund_amount::numeric,
        2
    ) AS refund_amount,

    ROUND(
        (
            s.revenue -
            r.refund_amount
        )::numeric,
        2
    ) AS net_revenue_after_refunds

FROM sales s

CROSS JOIN refunds r;


/*
Gross Revenue:
19,602,501.46

Refunds:
862,639.96

Net Revenue After Refunds:
18,739,861.50
*/


-- =========================================================
-- 4. CATEGORY-LEVEL RETURN PERFORMANCE
-- =========================================================

WITH category_sales AS (

    SELECT
        p.category,

        SUM(oi.quantity)
            AS units_sold,

        SUM(oi.revenue)
            AS revenue

    FROM orders o

    JOIN order_items oi
        ON o.order_id = oi.order_id

    JOIN products p
        ON oi.product_id = p.product_id

    WHERE
        o.order_status = 'Completed'

    GROUP BY
        p.category
),

category_returns AS (

    SELECT
        p.category,

        SUM(r.returned_quantity)
            AS returned_units,

        SUM(r.refund_amount)
            AS refund_amount

    FROM returns r

    JOIN order_items oi
        ON r.order_item_id = oi.order_item_id

    JOIN products p
        ON oi.product_id = p.product_id

    JOIN orders o
        ON oi.order_id = o.order_id

    WHERE
        r.return_status = 'Refunded'
        AND o.order_status = 'Completed'

    GROUP BY
        p.category
)

SELECT
    s.category,

    s.units_sold,

    COALESCE(
        r.returned_units,
        0
    ) AS returned_units,

    ROUND(
        (
            100.0 *
            COALESCE(r.returned_units, 0)
            /
            NULLIF(s.units_sold, 0)
        )::numeric,
        2
    ) AS unit_return_rate_pct,

    ROUND(
        s.revenue::numeric,
        2
    ) AS revenue,

    ROUND(
        COALESCE(
            r.refund_amount,
            0
        )::numeric,
        2
    ) AS refund_amount,

    ROUND(
        (
            100.0 *
            COALESCE(r.refund_amount, 0)
            /
            NULLIF(s.revenue, 0)
        )::numeric,
        2
    ) AS refund_to_revenue_pct

FROM category_sales s

LEFT JOIN category_returns r
    ON s.category = r.category

ORDER BY
    unit_return_rate_pct DESC;


/*
Important project findings:

Fashion
-------
Unit Return Rate: ~8.24%
Highest relative return burden.

Electronics
-----------
Unit Return Rate: ~4.32%
Refund Amount: ~550.85K

Electronics does not have the highest return rate,
but creates the largest absolute financial leakage
because of its much larger revenue base.
*/


-- =========================================================
-- 5. RETURN REASONS
-- =========================================================

SELECT
    return_reason,

    COUNT(*) AS return_records,

    SUM(returned_quantity)
        AS returned_units,

    ROUND(
        SUM(refund_amount)::numeric,
        2
    ) AS refund_amount,

    ROUND(
        (
            100.0 *
            SUM(refund_amount)
            /
            SUM(SUM(refund_amount)) OVER ()
        )::numeric,
        2
    ) AS refund_share_pct

FROM returns

WHERE
    return_status = 'Refunded'

GROUP BY
    return_reason

ORDER BY
    refund_amount DESC;


/*
Largest refund reasons:

Not as Expected  : ~220.79K
Poor Quality     : ~185.89K
Wrong Product    : ~165.33K
Damaged          : ~155.72K

Not as Expected + Poor Quality represented
approximately 47% of total refund value.
*/


-- =========================================================
-- 6. PRODUCT-LEVEL SALES BASE
-- =========================================================

WITH product_sales AS (

    SELECT
        p.product_id,
        p.product_name,
        p.category,

        SUM(oi.quantity)
            AS units_sold,

        SUM(oi.revenue)
            AS revenue,

        SUM(oi.profit)
            AS gross_profit

    FROM orders o

    JOIN order_items oi
        ON o.order_id = oi.order_id

    JOIN products p
        ON oi.product_id = p.product_id

    WHERE
        o.order_status = 'Completed'

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
        (
            100.0 * gross_profit /
            NULLIF(revenue, 0)
        )::numeric,
        2
    ) AS gross_margin_pct

FROM product_sales

ORDER BY
    revenue DESC;


-- =========================================================
-- 7. HIGH-RETURN PRODUCTS
-- Minimum 50 Units Sold
-- =========================================================

WITH product_sales AS (

    SELECT
        p.product_id,
        p.product_name,
        p.category,

        SUM(oi.quantity)
            AS units_sold,

        SUM(oi.revenue)
            AS revenue,

        SUM(oi.profit)
            AS gross_profit

    FROM orders o

    JOIN order_items oi
        ON o.order_id = oi.order_id

    JOIN products p
        ON oi.product_id = p.product_id

    WHERE
        o.order_status = 'Completed'

    GROUP BY
        p.product_id,
        p.product_name,
        p.category
),

product_returns AS (

    SELECT
        p.product_id,

        SUM(r.returned_quantity)
            AS returned_units,

        SUM(r.refund_amount)
            AS refund_amount

    FROM returns r

    JOIN order_items oi
        ON r.order_item_id = oi.order_item_id

    JOIN products p
        ON oi.product_id = p.product_id

    JOIN orders o
        ON oi.order_id = o.order_id

    WHERE
        r.return_status = 'Refunded'
        AND o.order_status = 'Completed'

    GROUP BY
        p.product_id
)

SELECT
    s.product_id,
    s.product_name,
    s.category,

    s.units_sold,

    COALESCE(
        r.returned_units,
        0
    ) AS returned_units,

    ROUND(
        (
            100.0 *
            COALESCE(r.returned_units, 0)
            /
            NULLIF(s.units_sold, 0)
        )::numeric,
        2
    ) AS unit_return_rate_pct,

    ROUND(
        s.revenue::numeric,
        2
    ) AS revenue,

    ROUND(
        (
            100.0 *
            s.gross_profit /
            NULLIF(s.revenue, 0)
        )::numeric,
        2
    ) AS gross_margin_pct,

    ROUND(
        COALESCE(
            r.refund_amount,
            0
        )::numeric,
        2
    ) AS refund_amount

FROM product_sales s

LEFT JOIN product_returns r
    ON s.product_id = r.product_id

WHERE
    s.units_sold >= 50

ORDER BY
    unit_return_rate_pct DESC,
    refund_amount DESC;


/*
A minimum threshold of 50 units sold is applied so that
very low-volume products do not dominate the ranking
because of unstable return-rate percentages.

Examples identified:

Womens Clothing 0894
Units Sold: 96
Return Rate: ~21.88%

Laptops 0930
Units Sold: 93
Return Rate: ~20.43%

Cables 1449
Units Sold: 50
Return Rate: ~20.00%
*/


-- =========================================================
-- 8. RETURN REASON BY PRODUCT CATEGORY
-- =========================================================

SELECT
    r.return_reason,
    p.category,

    SUM(
        r.returned_quantity
    ) AS returned_units,

    ROUND(
        SUM(r.refund_amount)::numeric,
        2
    ) AS refund_amount

FROM returns r

JOIN order_items oi
    ON r.order_item_id = oi.order_item_id

JOIN products p
    ON oi.product_id = p.product_id

JOIN orders o
    ON oi.order_id = o.order_id

WHERE
    r.return_status = 'Refunded'
    AND o.order_status = 'Completed'

GROUP BY
    r.return_reason,
    p.category

ORDER BY
    r.return_reason,
    refund_amount DESC;


/*
Patterns observed:

Electronics dominated high-value issues such as:
- Wrong Product
- Not as Expected
- Poor Quality
- Damaged

Fashion dominated:
- Changed Mind
- Size Issue

Home & Kitchen was the largest category associated
with Late Delivery refunds.
*/


-- =========================================================
-- 9. CATEGORY REFUND CONTRIBUTION
-- =========================================================

WITH category_refunds AS (

    SELECT
        p.category,

        SUM(r.refund_amount)
            AS refund_amount

    FROM returns r

    JOIN order_items oi
        ON r.order_item_id = oi.order_item_id

    JOIN products p
        ON oi.product_id = p.product_id

    JOIN orders o
        ON oi.order_id = o.order_id

    WHERE
        r.return_status = 'Refunded'
        AND o.order_status = 'Completed'

    GROUP BY
        p.category
)

SELECT
    category,

    ROUND(
        refund_amount::numeric,
        2
    ) AS refund_amount,

    ROUND(
        (
            100.0 *
            refund_amount /
            SUM(refund_amount) OVER ()
        )::numeric,
        2
    ) AS refund_share_pct

FROM category_refunds

ORDER BY
    refund_amount DESC;


/*
===========================================================
KEY BUSINESS TAKEAWAYS

1. Realized refunds reduced revenue by approximately
   862.64K, equivalent to about 4.40% of revenue.

2. Fashion had the highest relative unit return rate
   at approximately 8.24%.

3. Electronics created the largest absolute refund
   leakage at approximately 550.85K.

4. Not as Expected and Poor Quality together represented
   approximately 47% of refund value.

5. Several individual products showed return rates
   above 15-20%, even after applying a minimum sales
   volume threshold.

6. Electronics should be investigated for product
   descriptions/specifications, fulfillment accuracy,
   packaging and supplier quality.

7. Fashion return reduction should focus particularly
   on sizing, fit and expectation-setting.

8. Return rate and absolute refund value should both
   be considered when prioritizing corrective action.

===========================================================
*/