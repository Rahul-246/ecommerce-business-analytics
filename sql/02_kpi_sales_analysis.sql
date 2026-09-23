/*
===========================================================
E-COMMERCE BUSINESS ANALYTICS
02 - KPI & SALES ANALYSIS
===========================================================

Purpose:
Analyze overall business performance, revenue growth,
order volume, customer activity and sales trends.

Scope:
Only completed orders are included in sales KPIs.
*/


-- =========================================================
-- 1. EXECUTIVE KPIs
-- =========================================================

SELECT
    ROUND(SUM(oi.revenue)::numeric, 2) AS total_revenue,
    ROUND(SUM(oi.profit)::numeric, 2) AS gross_profit,

    ROUND(
        (100.0 * SUM(oi.profit) /
        NULLIF(SUM(oi.revenue), 0))::numeric,
        2
    ) AS gross_margin_pct,

    COUNT(DISTINCT o.order_id) AS completed_orders,

    COUNT(DISTINCT o.customer_id) AS purchasing_customers,

    ROUND(
        (SUM(oi.revenue) /
        NULLIF(COUNT(DISTINCT o.order_id), 0))::numeric,
        2
    ) AS average_order_value,

    SUM(oi.quantity) AS units_sold

FROM orders o

JOIN order_items oi
    ON o.order_id = oi.order_id

WHERE o.order_status = 'Completed';


-- =========================================================
-- 2. YEARLY SALES PERFORMANCE
-- =========================================================

SELECT
    EXTRACT(YEAR FROM o.order_date)::int AS year,

    COUNT(DISTINCT o.order_id) AS completed_orders,

    ROUND(
        SUM(oi.revenue)::numeric,
        2
    ) AS revenue,

    ROUND(
        SUM(oi.profit)::numeric,
        2
    ) AS gross_profit,

    ROUND(
        (100.0 * SUM(oi.profit) /
        NULLIF(SUM(oi.revenue), 0))::numeric,
        2
    ) AS gross_margin_pct,

    ROUND(
        (SUM(oi.revenue) /
        NULLIF(COUNT(DISTINCT o.order_id), 0))::numeric,
        2
    ) AS average_order_value

FROM orders o

JOIN order_items oi
    ON o.order_id = oi.order_id

WHERE o.order_status = 'Completed'

GROUP BY
    EXTRACT(YEAR FROM o.order_date)

ORDER BY
    year;


-- =========================================================
-- 3. YEAR-OVER-YEAR REVENUE GROWTH
-- =========================================================

WITH yearly_sales AS (

    SELECT
        EXTRACT(YEAR FROM o.order_date)::int AS year,
        SUM(oi.revenue) AS revenue

    FROM orders o

    JOIN order_items oi
        ON o.order_id = oi.order_id

    WHERE o.order_status = 'Completed'

    GROUP BY
        EXTRACT(YEAR FROM o.order_date)
),

growth AS (

    SELECT
        year,
        revenue,

        LAG(revenue)
        OVER (ORDER BY year) AS previous_year_revenue

    FROM yearly_sales
)

SELECT
    year,

    ROUND(
        revenue::numeric,
        2
    ) AS revenue,

    ROUND(
        previous_year_revenue::numeric,
        2
    ) AS previous_year_revenue,

    ROUND(
        (
            100.0 *
            (revenue - previous_year_revenue) /
            NULLIF(previous_year_revenue, 0)
        )::numeric,
        2
    ) AS yoy_growth_pct

FROM growth

ORDER BY year;


-- =========================================================
-- 4. MONTHLY REVENUE TREND
-- =========================================================

SELECT
    DATE_TRUNC(
        'month',
        o.order_date
    )::date AS month,

    COUNT(DISTINCT o.order_id) AS completed_orders,

    ROUND(
        SUM(oi.revenue)::numeric,
        2
    ) AS revenue,

    ROUND(
        SUM(oi.profit)::numeric,
        2
    ) AS gross_profit

FROM orders o

JOIN order_items oi
    ON o.order_id = oi.order_id

WHERE o.order_status = 'Completed'

GROUP BY
    DATE_TRUNC('month', o.order_date)

ORDER BY
    month;