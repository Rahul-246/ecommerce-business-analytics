# Dataset

This project uses a synthetic e-commerce dataset designed to simulate
real-world transactional, customer, product, payment, and return data.

The dataset covers transactions from January 2023 to December 2025.

## Dataset Structure

| Dataset | Rows | Description |
|---|---:|---|
| customers | 15,000 | Customer demographics, location and acquisition information |
| products | 1,500 | Product, category, supplier, pricing and cost information |
| orders | 45,000 | Order-level transaction information |
| order_items | 92,002 | Product-level items associated with each order |
| payments | 45,000 | Payment method, status, amount and transaction fee |
| returns | 5,416 | Product returns, reasons, quantities and refund amounts |

## Data Model

The primary relationships are:

- customers.customer_id → orders.customer_id
- orders.order_id → order_items.order_id
- products.product_id → order_items.product_id
- orders.order_id → payments.order_id
- order_items.order_item_id → returns.order_item_id

## Analysis Scope

The dataset supports analysis across:

- Revenue and sales growth
- Gross profit and margin
- Customer purchase behavior
- Repeat customer analysis
- RFM customer segmentation
- Product performance
- Discount impact
- Return rates
- Refund and revenue leakage
- Country and category performance

## Data Quality

Data validation was performed before analysis, including:

- Duplicate checks
- Missing-value checks
- Referential-integrity checks
- Invalid transaction-value checks
- Order/payment reconciliation
- Date consistency checks

A synthetic-data issue was identified where some customer signup dates
occurred after their first transaction. For analytical consistency, affected
signup dates were aligned with the customer's earliest recorded order date.

See:

`sql/01_data_quality.sql`

for the complete validation process.

## RFM Dataset

`customer_rfm.csv` contains the final customer-level RFM segmentation used
in the Power BI dashboard.

It includes:

- Customer ID
- Last Order Date
- Recency
- Frequency
- Monetary Value
- Recency Score
- Frequency Score
- Monetary Score
- RFM Segment

The final RFM segmentation was generated in Python with explicit tie
handling before quintile assignment.

## Important Note

The data used in this project is synthetic and was created specifically
for portfolio and analytical demonstration purposes.

It does not contain real customer or company information.
