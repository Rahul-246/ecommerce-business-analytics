/*
===========================================================
E-COMMERCE BUSINESS ANALYTICS
01 - DATA QUALITY & VALIDATION
===========================================================

Purpose:
Validate data completeness, integrity and consistency
before performing business analysis.

Dataset:
Customers, Products, Orders, Order Items, Payments, Returns
*/


-- =========================================================
-- 1. BASIC TABLE INSPECTION
-- =========================================================

SELECT * FROM customers LIMIT 10;
SELECT * FROM products LIMIT 10;
SELECT * FROM orders LIMIT 10;
SELECT * FROM order_items LIMIT 10;
SELECT * FROM payments LIMIT 10;
SELECT * FROM returns LIMIT 10;


-- =========================================================
-- 2. TABLE ROW COUNTS
-- =========================================================

SELECT 'customers' AS table_name, COUNT(*) AS row_count
FROM customers

UNION ALL

SELECT 'products', COUNT(*)
FROM products

UNION ALL

SELECT 'orders', COUNT(*)
FROM orders

UNION ALL

SELECT 'order_items', COUNT(*)
FROM order_items

UNION ALL

SELECT 'payments', COUNT(*)
FROM payments

UNION ALL

SELECT 'returns', COUNT(*)
FROM returns;


-- =========================================================
-- 3. ORDER DATE RANGE
-- =========================================================

SELECT
    MIN(order_date) AS first_order_date,
    MAX(order_date) AS last_order_date
FROM orders;


-- =========================================================
-- 4. ORDER STATUS DISTRIBUTION
-- =========================================================

SELECT
    order_status,
    COUNT(*) AS order_count
FROM orders
GROUP BY order_status
ORDER BY order_count DESC;


-- =========================================================
-- 5. DUPLICATE PRIMARY KEY CHECKS
-- =========================================================

-- Customers

SELECT
    customer_id,
    COUNT(*) AS duplicate_count
FROM customers
GROUP BY customer_id
HAVING COUNT(*) > 1;


-- Products

SELECT
    product_id,
    COUNT(*) AS duplicate_count
FROM products
GROUP BY product_id
HAVING COUNT(*) > 1;


-- Orders

SELECT
    order_id,
    COUNT(*) AS duplicate_count
FROM orders
GROUP BY order_id
HAVING COUNT(*) > 1;


-- Order Items

SELECT
    order_item_id,
    COUNT(*) AS duplicate_count
FROM order_items
GROUP BY order_item_id
HAVING COUNT(*) > 1;


-- =========================================================
-- 6. REFERENTIAL INTEGRITY / ORPHAN CHECKS
-- =========================================================

-- Orders without a valid customer

SELECT
    COUNT(*) AS orphan_orders
FROM orders o

LEFT JOIN customers c
    ON o.customer_id = c.customer_id

WHERE c.customer_id IS NULL;


-- Order items without a valid order

SELECT
    COUNT(*) AS orphan_order_items
FROM order_items oi

LEFT JOIN orders o
    ON oi.order_id = o.order_id

WHERE o.order_id IS NULL;


-- Order items without a valid product

SELECT
    COUNT(*) AS invalid_product_references
FROM order_items oi

LEFT JOIN products p
    ON oi.product_id = p.product_id

WHERE p.product_id IS NULL;


-- =========================================================
-- 7. MISSING VALUE CHECKS
-- =========================================================

SELECT
    COUNT(*) FILTER (
        WHERE customer_id IS NULL
    ) AS missing_customer_id,

    COUNT(*) FILTER (
        WHERE signup_date IS NULL
    ) AS missing_signup_date,

    COUNT(*) FILTER (
        WHERE marketing_source IS NULL
           OR TRIM(marketing_source) = ''
    ) AS missing_marketing_source

FROM customers;


SELECT
    COUNT(*) FILTER (
        WHERE order_id IS NULL
    ) AS missing_order_id,

    COUNT(*) FILTER (
        WHERE customer_id IS NULL
    ) AS missing_customer_id,

    COUNT(*) FILTER (
        WHERE order_date IS NULL
    ) AS missing_order_date,

    COUNT(*) FILTER (
        WHERE order_status IS NULL
    ) AS missing_order_status

FROM orders;


-- =========================================================
-- 8. INVALID TRANSACTION VALUES
-- =========================================================

SELECT

    COUNT(*) FILTER (
        WHERE quantity <= 0
    ) AS invalid_quantity,

    COUNT(*) FILTER (
        WHERE unit_price < 0
    ) AS invalid_unit_price,

    COUNT(*) FILTER (
        WHERE unit_cost < 0
    ) AS invalid_unit_cost,

    COUNT(*) FILTER (
        WHERE revenue < 0
    ) AS negative_revenue

FROM order_items;


-- =========================================================
-- 9. DISCOUNT & PROFIT RANGE CHECK
-- =========================================================

SELECT

    MIN(discount_pct) AS minimum_discount,

    MAX(discount_pct) AS maximum_discount,

    ROUND(
        AVG(discount_pct)::numeric,
        4
    ) AS average_discount,

    ROUND(
        MIN(profit)::numeric,
        2
    ) AS minimum_profit,

    ROUND(
        MAX(profit)::numeric,
        2
    ) AS maximum_profit,

    ROUND(
        AVG(profit)::numeric,
        2
    ) AS average_profit

FROM order_items;


-- =========================================================
-- 10. CUSTOMER SIGNUP DATE CONSISTENCY
-- =========================================================

/*
DATA QUALITY ISSUE IDENTIFIED:

19,678 orders were found where order_date occurred
before the corresponding customer's signup_date.

Root Cause:
The synthetic customer signup dates and transaction dates
were generated independently.

In a real production environment this issue should first
be investigated with the source-system or data engineering
team before modifying records.
*/

SELECT
    COUNT(*) AS orders_before_signup
FROM orders o

JOIN customers c
    ON o.customer_id = c.customer_id

WHERE o.order_date < c.signup_date;


-- =========================================================
-- 11. CORRECT SYNTHETIC SIGNUP DATE ISSUE
-- =========================================================

/*
For this synthetic analytical dataset, affected customer
signup dates were aligned with their earliest recorded
order date.
*/

WITH first_order AS (

    SELECT
        customer_id,
        MIN(order_date) AS first_order_date

    FROM orders

    GROUP BY customer_id
)

UPDATE customers c

SET signup_date = f.first_order_date

FROM first_order f

WHERE c.customer_id = f.customer_id
  AND c.signup_date > f.first_order_date;


-- =========================================================
-- 12. VALIDATE SIGNUP DATE CORRECTION
-- =========================================================

SELECT
    COUNT(*) AS orders_before_signup_after_correction

FROM orders o

JOIN customers c
    ON o.customer_id = c.customer_id

WHERE o.order_date < c.signup_date;

/*
Expected result after correction: 0
*/


-- =========================================================
-- 13. ORDER TOTAL RECONCILIATION
-- =========================================================

WITH calculated_order_totals AS (

    SELECT
        order_id,

        ROUND(
            SUM(revenue)::numeric,
            2
        ) AS calculated_revenue

    FROM order_items

    GROUP BY order_id
)

SELECT
    COUNT(*) AS order_total_mismatches

FROM orders o

JOIN calculated_order_totals cot
    ON o.order_id = cot.order_id

WHERE ROUND(o.order_total::numeric, 2)
      <> cot.calculated_revenue;

/*
Expected result: 0 mismatches
*/


-- =========================================================
-- 14. PAYMENT AMOUNT RECONCILIATION
-- =========================================================

SELECT
    COUNT(*) AS payment_amount_mismatches

FROM orders o

JOIN payments p
    ON o.order_id = p.order_id

WHERE ROUND(o.order_total::numeric, 2)
      <> ROUND(p.amount::numeric, 2);

/*
Expected result: 0 mismatches
*/


-- =========================================================
-- 15. ORDER STATUS VS PAYMENT STATUS
-- =========================================================

SELECT
    o.order_status,
    p.payment_status,
    COUNT(*) AS order_count

FROM orders o

JOIN payments p
    ON o.order_id = p.order_id

GROUP BY
    o.order_status,
    p.payment_status

ORDER BY
    order_count DESC;


/*
===========================================================
DATA QUALITY SUMMARY

Key validation findings from the project:

- 15,000 customers
- 1,500 products
- 45,000 orders
- 92,002 order items
- 45,000 payment records
- 5,416 return records

- No duplicate customer IDs identified
- No orphan orders identified
- No orphan order items identified
- No invalid product references identified
- No invalid quantities identified
- No negative revenue identified
- Order totals reconciled with item-level revenue
- Payment amounts reconciled with order totals

Synthetic-data issue:
19,678 orders originally occurred before customer signup
dates. The affected signup dates were aligned to each
customer's earliest recorded order date for this analysis.

===========================================================
*/