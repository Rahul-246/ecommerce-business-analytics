# Business Insights & Recommendations

## E-commerce Revenue, Customer & Product Analytics

This document summarizes the key business insights identified through SQL, Python, and Power BI analysis of the e-commerce dataset covering **2023–2025**.

The analysis focuses on five areas:

- Revenue growth
- Profitability and discounting
- Customer behavior and retention
- Product performance
- Returns and revenue leakage

---

# 1. Revenue Growth

## Business Question

Is the business growing, and what is driving that growth?

## Finding

Revenue increased consistently from 2023 to 2025.

| Year | Completed Orders | Revenue | Gross Profit | Gross Margin |
|---|---:|---:|---:|---:|
| 2023 | 12,746 | 5.80M | 1.45M | 24.96% |
| 2024 | 14,172 | 6.45M | 1.60M | 24.77% |
| 2025 | 16,083 | 7.35M | 1.82M | 24.72% |

Revenue grew approximately:

- **11.16% in 2024**
- **14.03% in 2025**

However, Average Order Value remained relatively stable:

| Year | AOV |
|---|---:|
| 2023 | 455.14 |
| 2024 | 455.01 |
| 2025 | 457.19 |

## Business Implication

Revenue growth was driven primarily by **increasing transaction volume rather than customers spending substantially more per order**.

This means continued growth depends heavily on maintaining or increasing order volume.

## Recommended Action

Management should monitor both:

- Order growth
- Average Order Value

Potential growth initiatives can focus on increasing basket value through product bundling, cross-selling, and relevant recommendations while protecting margins.

---

# 2. Strong Seasonality

## Business Question

Are there periods when customer demand is significantly higher?

## Finding

The monthly revenue analysis shows strong year-end seasonality.

The highest monthly revenue occurred in:

**December 2025 — approximately 989.92K**

The lowest monthly revenue occurred in:

**January 2023 — approximately 344.85K**

November and December consistently showed stronger sales activity.

## Business Implication

The company has meaningful seasonal demand patterns.

Peak periods can create opportunities for revenue growth but may also increase pressure on inventory, fulfillment, customer support, and logistics.

## Recommended Action

Use historical seasonality to support:

- Inventory planning
- Marketing campaign timing
- Staffing decisions
- Fulfillment capacity planning
- Promotional scheduling

---

# 3. Electronics Drives Revenue but Has Margin Pressure

## Business Question

Which categories drive business performance?

## Finding

Electronics is the dominant revenue category.

| Category | Revenue | Gross Profit | Gross Margin |
|---|---:|---:|---:|
| Electronics | 12.79M | 2.32M | 18.12% |
| Home & Kitchen | 2.06M | 646.49K | 31.40% |
| Fashion | 1.99M | 837.45K | 42.03% |
| Sports | 763.54K | 272.49K | 35.69% |
| Office | 675.35K | 202.66K | 30.01% |
| Beauty | 565.54K | 286.51K | 50.66% |
| Accessories | 536.30K | 235.52K | 43.92% |
| Books | 218.99K | 63.58K | 29.03% |

Electronics contributes roughly **65% of company revenue**.

However, its gross margin of approximately **18.12%** is substantially below several other categories.

Beauty has the highest category margin at approximately **50.66%**.

## Business Implication

Revenue alone does not provide a complete picture of product performance.

Electronics is strategically important because of its scale, but its lower margin means pricing, discounting, sourcing, and cost decisions in this category can materially affect company profitability.

## Recommended Action

Management should evaluate Electronics at the product level using:

**Revenue + Gross Profit + Gross Margin + Discount + Return Rate**

High-revenue products with weak margins should receive additional pricing and cost review.

---

# 4. Some High-Revenue Products Have Weak Margins

## Business Question

Are all high-selling products equally attractive financially?

## Finding

The analysis identified **81 products** generating at least 10K in revenue while operating below a 15% gross margin.

For example:

**Headphones 0169**

- Revenue: ~454.37K
- Gross Profit: ~63.14K
- Gross Margin: ~13.90%

Another example:

**Laptops 1110**

- Revenue: ~184.76K
- Gross Profit: ~16.30K
- Gross Margin: ~8.82%

## Business Implication

A product can generate substantial revenue while contributing relatively little profit per unit of revenue.

Ranking products only by sales can therefore hide profitability problems.

## Recommended Action

Create a recurring product profitability review that combines:

- Revenue
- Units sold
- Gross profit
- Gross margin
- Discount rate
- Return rate
- Refund amount

Products with high revenue but persistently weak margins should be reviewed for pricing, supplier cost, promotions, or assortment decisions.

---

# 5. Discounting Is Associated With Margin Compression

## Business Question

How does discounting relate to profitability?

## Finding

Gross margin generally declined as discounts increased through the 0–20% range.

| Discount Band | Revenue | Gross Margin | Loss-Making Lines |
|---|---:|---:|---:|
| 0% | 11.55M | 28.75% | 0 |
| 1–5% | 1.64M | 26.55% | 1 |
| 6–10% | 2.38M | 21.88% | 48 |
| 11–20% | 3.96M | 14.32% | 1,062 |
| 21–30% | 65.63K | 26.25% | 2 |

Across completed transactions:

**1,113 order lines were loss-making.**

Average discount:

- Loss-making lines: **18.31%**
- Profitable lines: **5.86%**

Approximately **95% of loss-making lines** occurred in the 11–20% discount band.

## Business Implication

Higher discounting is associated with increased margin pressure in this dataset.

However, this analysis does **not establish causation**. Product mix, underlying unit cost, pricing, and promotional strategy can also influence profitability.

The 21–30% discount band should also not be interpreted as evidence that deeper discounts improve margins because it contains substantially fewer observations and a different product mix.

## Recommended Action

Avoid using a single discount policy across all products.

Discount decisions should consider:

- Product margin
- Product cost
- Category
- Customer segment
- Inventory objectives
- Expected incremental demand

High-discount campaigns should be evaluated using **incremental profit**, not revenue alone.

---

# 6. Repeat Customers Are Significantly More Valuable

## Business Question

How important are repeat customers?

## Finding

The business had **11,279 purchasing customers**.

Of these:

- Repeat Customers: **7,897**
- One-Time Customers: **3,382**
- Repeat Purchase Rate: **70.02%**

Customer economics differed substantially.

| Customer Type | Avg Orders | Avg Revenue | Avg Profit |
|---|---:|---:|---:|
| Repeat | 5.02 | ~2,284 | ~567 |
| One-Time | 1.00 | ~462 | ~114 |

Repeat customers generated approximately **5x the average revenue and profit** of one-time customers.

## Business Implication

Customer retention is closely associated with substantially higher customer value.

This does not prove that repeat purchasing itself caused higher profitability, but it demonstrates that repeat customers represent an economically important group.

## Recommended Action

Track customer retention alongside acquisition metrics.

Potential initiatives include:

- Post-purchase engagement
- Personalized recommendations
- Loyalty programs
- Replenishment reminders
- Targeted offers
- Win-back campaigns

---

# 7. Customer Revenue Is Highly Concentrated

## Business Question

Is customer value evenly distributed?

## Finding

Customer revenue is strongly right-skewed.

Average customer revenue was approximately:

**1,737.96**

Median customer revenue was approximately:

**1,025.58**

Revenue concentration analysis showed:

- Top 10% of customers → **~39.39% of revenue**
- Top 20% → **~58.39%**
- Top 30% → **~71.27%**

## Business Implication

A relatively small proportion of customers generates a large share of company revenue.

Losing high-value customers could therefore have a disproportionate business impact.

## Recommended Action

Use value-based customer management instead of treating all customers identically.

High-value customers should receive stronger retention attention, while lower-value segments should be managed using cost-effective engagement strategies.

---

# 8. RFM Segmentation Identifies Strategic Customer Groups

## Business Question

Which customers should receive different retention or engagement strategies?

## Finding

Customers were segmented using:

- **Recency**
- **Frequency**
- **Monetary Value**

Final segmentation used in Power BI:

| Segment | Customers | Revenue |
|---|---:|---:|
| Champions | 2,340 | 10.13M |
| Loyal | 1,293 | 2.96M |
| Others | 2,487 | 2.20M |
| Lost | 2,913 | 1.56M |
| Potential Loyalists | 1,652 | 1.42M |
| At Risk | 594 | 1.33M |

Champions generated approximately **half of total customer revenue**.

The At Risk segment contained only 594 customers but had historically generated approximately **1.33M in revenue**.

## Business Implication

Customer strategy should differ significantly by customer lifecycle and value.

A high-value customer who has stopped purchasing should not receive the same treatment as a low-value inactive customer.

## Recommended Action

### Champions

Focus on retention, loyalty benefits, early access, and personalized engagement.

### Loyal

Use cross-selling, recommendations, and loyalty incentives.

### Potential Loyalists

Encourage additional purchases and move customers toward repeat behavior.

### At Risk

Prioritize targeted reactivation because these customers have demonstrated meaningful historical value.

### Lost

Use selective win-back campaigns where expected customer value justifies acquisition cost.

---

# 9. Returns Reduce Revenue by More Than 860K

## Business Question

What is the financial impact of returns?

## Finding

Using only finalized returns with status **Refunded**:

- Refunded Units: **5,366**
- Orders With Refunds: **4,264**
- Refund Amount: **862.64K**
- Unit Return Rate: **4.34%**
- Order Return Rate: **9.92%**
- Refund-to-Revenue: **4.40%**

Revenue before refunds:

**19.60M**

Net revenue after finalized refunds:

**18.74M**

## Business Implication

Returns represent meaningful revenue leakage.

Reducing preventable returns can potentially improve realized revenue without requiring equivalent new customer acquisition.

## Recommended Action

Return reduction should be treated as both a customer-experience and profitability initiative.

Track:

- Return rate
- Refund amount
- Return reason
- Product
- Category
- Supplier

---

# 10. Fashion Has the Highest Relative Return Risk

## Business Question

Which category has the greatest return-rate problem?

## Finding

Fashion had the highest unit return rate:

**8.24%**

Other notable category rates included:

- Electronics: 4.32%
- Accessories: 4.07%
- Sports: 3.56%
- Home & Kitchen: 3.32%

## Business Implication

Fashion has the strongest relative return problem.

Size, fit, product presentation, and expectation mismatch are likely areas for operational investigation based on the recorded return-reason patterns.

## Recommended Action

Potential Fashion improvements include:

- Better sizing guides
- Fit information
- More detailed product descriptions
- Improved product photography
- Customer reviews and fit feedback

---

# 11. Electronics Creates the Largest Absolute Refund Leakage

## Business Question

Which category has the greatest financial impact from returns?

## Finding

Although Fashion had the highest return rate, Electronics generated approximately:

**550.85K in refunds**

Electronics therefore represents the largest **absolute financial leakage** from returns.

## Business Implication

Return rate and refund value answer different business questions.

- **Return Rate** → relative product/category risk
- **Refund Amount** → financial impact

Prioritizing only the highest return-rate category could cause management to overlook a larger financial opportunity.

## Recommended Action

Use both metrics when prioritizing return-reduction initiatives.

Electronics should receive strong attention because even relatively small improvements could have meaningful financial impact due to its scale.

---

# 12. Return Reasons Point to Specific Operational Problems

## Business Question

Why are customers returning products?

## Finding

The largest finalized refund reasons were:

| Return Reason | Refund Amount | Share |
|---|---:|---:|
| Not as Expected | 220.79K | 25.59% |
| Poor Quality | 185.89K | 21.55% |
| Wrong Product | 165.33K | 19.17% |
| Damaged | 155.72K | 18.05% |
| Changed Mind | 74.86K | 8.68% |
| Size Issue | 40.34K | 4.68% |
| Late Delivery | 19.73K | 2.29% |

**Not as Expected + Poor Quality represented approximately 47% of total refund value.**

Category analysis also revealed different patterns:

- Electronics dominated high-value quality, expectation, damage, and incorrect-product issues.
- Fashion dominated size and changed-mind returns.
- Home & Kitchen had the strongest late-delivery contribution.

## Business Implication

Returns are not one problem.

Different categories appear to require different operational responses.

## Recommended Action

### Electronics

Investigate:

- Product specifications and descriptions
- Supplier quality
- Packaging
- Fulfillment accuracy
- Product-condition controls

### Fashion

Improve:

- Sizing information
- Fit guidance
- Product presentation
- Expectation-setting

### Home & Kitchen

Investigate:

- Delivery lead times
- Logistics performance
- Fulfillment processes

---

# 13. Product-Level Return Risk Requires Volume Context

## Business Question

Which individual products require investigation?

## Finding

Several products had unusually high return rates even after requiring at least **50 units sold**.

Examples:

| Product | Units Sold | Return Rate |
|---|---:|---:|
| Womens Clothing 0894 | 96 | 21.88% |
| Laptops 0930 | 93 | 20.43% |
| Cables 1449 | 50 | 20.00% |
| Accessories 0793 | 82 | 18.29% |
| Womens Clothing 0223 | 58 | 17.24% |

The minimum-volume threshold was used to reduce the risk of ranking products based on unstable percentages from very small sales volumes.

## Business Implication

A high return rate alone is insufficient for prioritization.

Product risk should be assessed using:

**Return Rate + Sales Volume + Refund Value + Revenue + Margin**

## Recommended Action

Create a product-risk monitoring process that flags SKUs combining:

- High return rate
- Meaningful sales volume
- High refund value
- Weak margin

These products should receive priority investigation.

---

# Overall Business Priorities

Based on the combined analysis, the strongest opportunities are:

1. **Protect high-value and repeat customers**
2. **Reactivate historically valuable At Risk customers**
3. **Review high-discount, low-margin product activity**
4. **Protect Electronics revenue while improving margin quality**
5. **Reduce Fashion's high relative return rate**
6. **Reduce Electronics' high absolute refund leakage**
7. **Investigate high-return individual products**
8. **Plan inventory and operations around year-end seasonality**
9. **Evaluate performance using profitability, not revenue alone**

---

# Conclusion

The analysis shows a business with consistent revenue growth and a strong repeat-customer base, but also identifies important profitability and operational risks.

The central analytical lesson is that **growth alone is not enough**.

Revenue should be evaluated alongside:

**Profitability + Customer Value + Discounting + Product Risk + Returns**

Combining SQL, Python, customer segmentation, and Power BI makes it possible to move from reporting historical performance to identifying specific areas where management can investigate and act.

---

## Analysis Stack

**PostgreSQL | SQL | Python | Pandas | Power BI**

Detailed analytical code is available in the `sql/` and `python/` directories of this repository.
