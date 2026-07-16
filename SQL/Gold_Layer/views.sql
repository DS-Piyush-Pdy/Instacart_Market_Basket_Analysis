/*
===============================================================================
 Gold Layer ETL Script

 Description:
 This script creates analytical views from the Silver layer.
 These views are optimized for business reporting and Power BI dashboards.

 Views Created:
    1. Product Performance
    2. Department Performance
    3. Customer Summary
    4. Order Time Analysis
    5. Aisle Performance
    6. Basket Summary
===============================================================================
*/

-- ============================================================================
-- STEP 1 : CREATE GOLD SCHEMA
-- ============================================================================

CREATE SCHEMA IF NOT EXISTS gold;

-- ============================================================================
-- VIEW 1 : PRODUCT PERFORMANCE
-- ============================================================================

CREATE OR REPLACE VIEW gold.product_performance AS

SELECT

    p.product_id,
    p.product_name,
    d.department,
    a.aisle,

    COUNT(op.order_id) AS total_orders,

    SUM(op.reordered) AS total_reordered,

    ROUND(
        SUM(op.reordered)::NUMERIC
        /
        COUNT(op.order_id),
        2
    ) AS reorder_rate,

    ROUND(
        AVG(op.add_to_cart_order),
        2
    ) AS avg_cart_position

FROM silver.products p

JOIN silver.aisles a
ON p.aisle_id = a.aisle_id

JOIN silver.departments d
ON p.department_id = d.department_id

JOIN silver.order_products_prior op
ON p.product_id = op.product_id

GROUP BY

    p.product_id,
    p.product_name,
    d.department,
    a.aisle;

-- Verify View

SELECT *
FROM gold.product_performance
LIMIT 20;

-- ============================================================================
-- VIEW 2 : DEPARTMENT PERFORMANCE
-- ============================================================================

CREATE OR REPLACE VIEW gold.department_performance AS

SELECT

    d.department_id,
    d.department,

    COUNT(op.order_id) AS total_orders,

    COUNT(DISTINCT op.product_id) AS unique_products,

    SUM(op.reordered) AS total_reorders,

    ROUND(
        SUM(op.reordered)::NUMERIC
        /
        COUNT(op.order_id),
        2
    ) AS reorder_rate,

    ROUND(
        AVG(op.add_to_cart_order),
        2
    ) AS avg_cart_position

FROM silver.departments d

JOIN silver.products p
ON d.department_id = p.department_id

JOIN silver.order_products_prior op
ON p.product_id = op.product_id

GROUP BY

    d.department_id,
    d.department;

-- Verify View

SELECT *
FROM gold.department_performance
LIMIT 20;

-- ============================================================================
-- VIEW 3 : CUSTOMER SUMMARY
-- ============================================================================

CREATE OR REPLACE VIEW gold.customer_summary AS

SELECT

    o.user_id,

    COUNT(DISTINCT o.order_id) AS total_orders,

    COUNT(op.product_id) AS total_products_purchased,

    COUNT(DISTINCT op.product_id) AS unique_products_purchased,

    ROUND(
        COUNT(op.product_id)::NUMERIC
        /
        COUNT(DISTINCT o.order_id),
        2
    ) AS avg_basket_size,

    SUM(op.reordered) AS total_reordered_items,

    ROUND(
        SUM(op.reordered)::NUMERIC
        /
        COUNT(op.product_id),
        2
    ) AS reorder_rate

FROM silver.orders o

JOIN silver.order_products_prior op
ON o.order_id = op.order_id

GROUP BY

    o.user_id;

-- Verify View

SELECT *
FROM gold.customer_summary
LIMIT 20;

-- ============================================================================
-- VIEW 4 : ORDER TIME ANALYSIS
-- ============================================================================

CREATE OR REPLACE VIEW gold.order_time_analysis AS

SELECT

    order_day_name,

    order_time_category,

    COUNT(order_id) AS total_orders,

    COUNT(DISTINCT user_id) AS unique_customers,

    ROUND(
        AVG(order_number),
        2
    ) AS avg_order_number

FROM silver.orders

GROUP BY

    order_day_name,
    order_time_category;

-- Verify View

SELECT *
FROM gold.order_time_analysis
LIMIT 20;

-- ============================================================================
-- VIEW 5 : AISLE PERFORMANCE
-- ============================================================================

CREATE OR REPLACE VIEW gold.aisle_performance AS

SELECT

    a.aisle_id,
    a.aisle,

    COUNT(op.order_id) AS total_orders,

    COUNT(DISTINCT op.product_id) AS unique_products,

    SUM(op.reordered) AS total_reorders,

    ROUND(
        SUM(op.reordered)::NUMERIC
        /
        COUNT(op.order_id),
        2
    ) AS reorder_rate,

    ROUND(
        AVG(op.add_to_cart_order),
        2
    ) AS avg_cart_position

FROM silver.aisles a

JOIN silver.products p
ON a.aisle_id = p.aisle_id

JOIN silver.order_products_prior op
ON p.product_id = op.product_id

GROUP BY

    a.aisle_id,
    a.aisle;

-- Verify View

SELECT *
FROM gold.aisle_performance
LIMIT 20;

-- ============================================================================
-- VIEW 6 : BASKET SUMMARY
-- ============================================================================

CREATE OR REPLACE VIEW gold.basket_summary AS

SELECT

    op.order_id,

    COUNT(op.product_id) AS basket_size,

    SUM(op.reordered) AS reordered_items,

    ROUND(
        AVG(op.add_to_cart_order),
        2
    ) AS avg_cart_position,

    CASE
        WHEN COUNT(op.product_id) <= 5 THEN 'Small Basket'
        WHEN COUNT(op.product_id) BETWEEN 6 AND 15 THEN 'Medium Basket'
        ELSE 'Large Basket'
    END AS basket_category

FROM silver.order_products_prior op

GROUP BY

    op.order_id;

-- Verify View

SELECT *
FROM gold.basket_summary
LIMIT 20;

/*
===============================================================================
 End of Gold Layer
===============================================================================
*/
