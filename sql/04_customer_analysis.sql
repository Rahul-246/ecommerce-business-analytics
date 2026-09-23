/*
===========================================================
E-COMMERCE BUSINESS ANALYTICS
04 - CUSTOMER ANALYSIS
===========================================================

Purpose:
Analyze customer purchasing behavior, repeat purchases,
customer value and revenue concentration.

Scope:
Only completed orders are included.
*/


-- =========================================================
-- 1. CUSTOMER-LEVEL PERFORMANCE
-- =========================================================

WITH customer_summary AS (

    SELECT
        o.customer_id,

        COUNT(DISTINCT o.order_id) AS total_orders,

        SUM(oi.quantity) AS units_purchased,

        SUM(oi.revenue) AS total_revenue,

        SUM(oi.profit) AS total_profit

    FROM orders o

    JOIN order_items oi
        ON o.order_id = oi.order_id

    WHERE o.order_status = 'Completed'

    GROUP BY
        o.customer_id
)

SELECT
    cs.customer_id,
    c.country,

    cs.total_orders,
    cs.units_purchased,

    ROUND(
        cs.total_revenue::numeric,
        2
    ) AS total_revenue,

    ROUND(
        cs.total_profit::numeric,
        2
    ) AS total_profit,

    ROUND(
        (
            cs.total_revenue /
            NULLIF(cs.total_orders, 0)
        )::numeric,
        2
    ) AS average_order_value

FROM customer_summary cs

JOIN customers c
    ON cs.customer_id = c.customer_id

ORDER BY
    cs.total_revenue DESC;


/*
This query creates a customer-level analytical view
containing purchase frequency, revenue, profit and AOV.
*/


-- =========================================================
-- 2. TOP 10 CUSTOMERS BY LIFETIME REVENUE
-- =========================================================

WITH customer_summary AS (

    SELECT
        o.customer_id,

        COUNT(DISTINCT o.order_id) AS total_orders,

        SUM(oi.revenue) AS total_revenue,

        SUM(oi.profit) AS total_profit

    FROM orders o

    JOIN order_items oi
        ON o.order_id = oi.order_id

    WHERE o.order_status = 'Completed'

    GROUP BY
        o.customer_id
)

SELECT
    cs.customer_id,
    c.country,
    cs.total_orders,

    ROUND(
        cs.total_revenue::numeric,
        2
    ) AS total_revenue,

    ROUND(
        cs.total_profit::numeric,
        2
    ) AS total_profit,

    ROUND(
        (
            cs.total_revenue /
            NULLIF(cs.total_orders, 0)
        )::numeric,
        2
    ) AS average_order_value

FROM customer_summary cs

JOIN customers c
    ON cs.customer_id = c.customer_id

ORDER BY
    cs.total_revenue DESC

LIMIT 10;


/*
The highest-value customers were identified using
lifetime revenue across completed orders.
*/


-- =========================================================
-- 3. CUSTOMER PURCHASE FREQUENCY DISTRIBUTION
-- =========================================================

WITH customer_orders AS (

    SELECT
        customer_id,

        COUNT(*) AS completed_orders

    FROM orders

    WHERE order_status = 'Completed'

    GROUP BY
        customer_id
)

SELECT
    completed_orders,

    COUNT(*) AS number_of_customers

FROM customer_orders

GROUP BY
    completed_orders

ORDER BY
    completed_orders;


/*
This distribution helps distinguish occasional buyers
from highly frequent customers.

Median customer order frequency was approximately
2 completed orders.
*/


-- =========================================================
-- 4. REPEAT PURCHASE ANALYSIS
-- =========================================================

WITH customer_orders AS (

    SELECT
        customer_id,

        COUNT(*) AS completed_orders

    FROM orders

    WHERE order_status = 'Completed'

    GROUP BY
        customer_id
)

SELECT

    COUNT(*) AS purchasing_customers,

    COUNT(*) FILTER (
        WHERE completed_orders > 1
    ) AS repeat_customers,

    COUNT(*) FILTER (
        WHERE completed_orders = 1
    ) AS one_time_customers,

    ROUND(
        (
            100.0 *
            COUNT(*) FILTER (WHERE completed_orders > 1)
            /
            NULLIF(COUNT(*), 0)
        )::numeric,
        2
    ) AS repeat_purchase_rate_pct,

    ROUND(
        AVG(completed_orders)::numeric,
        2
    ) AS average_orders_per_customer

FROM customer_orders;


/*
Project results:

Purchasing Customers : 11,279
Repeat Customers     : 7,897
One-Time Customers   : 3,382
Repeat Purchase Rate : 70.02%
Average Orders       : ~3.81 per customer
*/


-- =========================================================
-- 5. ONE-TIME VS REPEAT CUSTOMER VALUE
-- =========================================================

WITH customer_summary AS (

    SELECT
        o.customer_id,

        COUNT(DISTINCT o.order_id) AS total_orders,

        SUM(oi.revenue) AS total_revenue,

        SUM(oi.profit) AS total_profit

    FROM orders o

    JOIN order_items oi
        ON o.order_id = oi.order_id

    WHERE o.order_status = 'Completed'

    GROUP BY
        o.customer_id
),

customer_type AS (

    SELECT
        *,

        CASE

            WHEN total_orders = 1
                THEN 'One-Time'

            ELSE 'Repeat'

        END AS purchase_type

    FROM customer_summary
)

SELECT
    purchase_type,

    COUNT(*) AS customers,

    ROUND(
        AVG(total_orders)::numeric,
        2
    ) AS average_orders,

    ROUND(
        AVG(total_revenue)::numeric,
        2
    ) AS average_customer_revenue,

    ROUND(
        PERCENTILE_CONT(0.5)
        WITHIN GROUP (
            ORDER BY total_revenue
        )::numeric,
        2
    ) AS median_customer_revenue,

    ROUND(
        AVG(total_profit)::numeric,
        2
    ) AS average_customer_profit,

    ROUND(
        SUM(total_revenue)::numeric,
        2
    ) AS total_revenue

FROM customer_type

GROUP BY
    purchase_type

ORDER BY
    total_revenue DESC;


/*
Project findings:

Repeat Customers
----------------
Customers: 7,897
Average Orders: ~5.02
Average Revenue: ~2,284
Average Profit: ~567

One-Time Customers
------------------
Customers: 3,382
Average Orders: 1
Average Revenue: ~462
Average Profit: ~114

Repeat customers generated approximately 5x the
average revenue and profit of one-time customers.

This is an association and should not be interpreted
as proof that repeat purchasing itself causes higher
customer profitability.
*/


-- =========================================================
-- 6. CUSTOMER REVENUE DISTRIBUTION
-- =========================================================

WITH customer_revenue AS (

    SELECT
        o.customer_id,

        SUM(oi.revenue) AS total_revenue

    FROM orders o

    JOIN order_items oi
        ON o.order_id = oi.order_id

    WHERE o.order_status = 'Completed'

    GROUP BY
        o.customer_id
)

SELECT

    COUNT(*) AS customers,

    ROUND(
        AVG(total_revenue)::numeric,
        2
    ) AS average_customer_revenue,

    ROUND(
        PERCENTILE_CONT(0.50)
        WITHIN GROUP (
            ORDER BY total_revenue
        )::numeric,
        2
    ) AS median_customer_revenue,

    ROUND(
        PERCENTILE_CONT(0.90)
        WITHIN GROUP (
            ORDER BY total_revenue
        )::numeric,
        2
    ) AS percentile_90_revenue,

    ROUND(
        PERCENTILE_CONT(0.95)
        WITHIN GROUP (
            ORDER BY total_revenue
        )::numeric,
        2
    ) AS percentile_95_revenue

FROM customer_revenue;


/*
Approximate project results:

Average Customer Revenue : 1,737.96
Median Customer Revenue  : 1,025.58
90th Percentile          : 4,183.57
95th Percentile          : 5,690.09

The difference between mean and median indicates
a right-skewed customer revenue distribution.
*/


-- =========================================================
-- 7. CUSTOMER REVENUE DECILES
-- =========================================================

WITH customer_revenue AS (

    SELECT
        o.customer_id,

        SUM(oi.revenue) AS revenue

    FROM orders o

    JOIN order_items oi
        ON o.order_id = oi.order_id

    WHERE o.order_status = 'Completed'

    GROUP BY
        o.customer_id
),

ranked_customers AS (

    SELECT
        customer_id,
        revenue,

        NTILE(10) OVER (
            ORDER BY revenue DESC
        ) AS revenue_decile

    FROM customer_revenue
),

decile_summary AS (

    SELECT
        revenue_decile,

        COUNT(*) AS customers,

        SUM(revenue) AS revenue

    FROM ranked_customers

    GROUP BY
        revenue_decile
)

SELECT
    revenue_decile,
    customers,

    ROUND(
        revenue::numeric,
        2
    ) AS revenue,

    ROUND(
        (
            100.0 * revenue /
            SUM(revenue) OVER ()
        )::numeric,
        2
    ) AS revenue_share_pct,

    ROUND(
        (
            100.0 *
            SUM(revenue) OVER (
                ORDER BY revenue_decile
            )
            /
            SUM(revenue) OVER ()
        )::numeric,
        2
    ) AS cumulative_revenue_share_pct

FROM decile_summary

ORDER BY
    revenue_decile;


/*
Revenue concentration observed in the project:

Top 10% of customers: ~39.39% of revenue
Top 20% of customers: ~58.39% of revenue
Top 30% of customers: ~71.27% of revenue

This shows substantial customer-value concentration.
*/


-- =========================================================
-- 8. CUSTOMER VALUE DATASET FOR FURTHER ANALYSIS
-- =========================================================

SELECT
    o.customer_id,

    COUNT(DISTINCT o.order_id) AS total_orders,

    SUM(oi.quantity) AS units_purchased,

    ROUND(
        SUM(oi.revenue)::numeric,
        2
    ) AS total_revenue,

    ROUND(
        SUM(oi.profit)::numeric,
        2
    ) AS total_profit,

    ROUND(
        (
            SUM(oi.revenue) /
            NULLIF(COUNT(DISTINCT o.order_id), 0)
        )::numeric,
        2
    ) AS average_order_value

FROM orders o

JOIN order_items oi
    ON o.order_id = oi.order_id

WHERE o.order_status = 'Completed'

GROUP BY
    o.customer_id

ORDER BY
    total_revenue DESC;


/*
===========================================================
KEY BUSINESS TAKEAWAYS

1. Approximately 70% of purchasing customers made
   more than one completed purchase.

2. Repeat customers generated substantially higher
   average revenue and profit than one-time customers.

3. Customer revenue is right-skewed, meaning a relatively
   small group of customers contributes a disproportionate
   share of business value.

4. The top 20% of customers generated approximately
   58% of total revenue.

5. High-value customer retention therefore represents
   an important business opportunity.

6. RFM segmentation is performed separately in the
   next stage to distinguish Champions, Loyal,
   At Risk and other customer groups.

===========================================================
*/