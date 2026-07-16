/*
===============================================================================

 Description:
 This script loads data from the Bronze layer into the Silver layer by
 performing data cleansing, standardization, deduplication, and basic
 feature engineering.

 Transformations Performed:
    • Remove duplicate records
    • Remove NULL primary keys
    • Standardize text values
    • Replace NULL text values with 'Unknown'
    • Validate numeric values
    • Create business-friendly derived columns
        - order_day_name
        - order_time_category

===============================================================================
*/

-- ============================================================================
-- STEP 1 : CLEAR EXISTING DATA
-- ============================================================================

TRUNCATE TABLE silver.order_products_train;
TRUNCATE TABLE silver.order_products_prior;
TRUNCATE TABLE silver.orders;
TRUNCATE TABLE silver.products;
TRUNCATE TABLE silver.aisles;
TRUNCATE TABLE silver.departments;

-- ============================================================================
-- STEP 2 : LOAD ORDERS
-- ============================================================================

INSERT INTO silver.orders
(
    order_id,
    user_id,
    eval_set,
    order_number,
    order_dow,
    order_day_name,
    order_hour_of_day,
    order_time_category,
    days_since_prior_order
)

SELECT

    order_id,
    user_id,

    LOWER(TRIM(eval_set)),

    order_number,

    order_dow,

    CASE
        WHEN order_dow = 0 THEN 'Sunday'
        WHEN order_dow = 1 THEN 'Monday'
        WHEN order_dow = 2 THEN 'Tuesday'
        WHEN order_dow = 3 THEN 'Wednesday'
        WHEN order_dow = 4 THEN 'Thursday'
        WHEN order_dow = 5 THEN 'Friday'
        WHEN order_dow = 6 THEN 'Saturday'
    END AS order_day_name,

    order_hour_of_day,

    CASE
        WHEN order_hour_of_day BETWEEN 5 AND 11 THEN 'Morning'
        WHEN order_hour_of_day BETWEEN 12 AND 16 THEN 'Afternoon'
        WHEN order_hour_of_day BETWEEN 17 AND 20 THEN 'Evening'
        ELSE 'Night'
    END AS order_time_category,

    days_since_prior_order

FROM
(
    SELECT *,
           ROW_NUMBER() OVER
           (
               PARTITION BY order_id
               ORDER BY order_id
           ) AS rn

    FROM bronze.orders

    WHERE order_id IS NOT NULL

) t

WHERE rn = 1;

-- ============================================================================
-- STEP 3 : LOAD PRODUCTS
-- ============================================================================

INSERT INTO silver.products

SELECT

    product_id,

    COALESCE(TRIM(product_name), 'Unknown'),

    aisle_id,

    department_id

FROM
(
    SELECT *,
           ROW_NUMBER() OVER
           (
               PARTITION BY product_id
               ORDER BY product_id
           ) AS rn

    FROM bronze.products

    WHERE product_id IS NOT NULL

) t

WHERE rn = 1;

-- ============================================================================
-- STEP 4 : LOAD AISLES
-- ============================================================================

INSERT INTO silver.aisles

SELECT

    aisle_id,

    COALESCE(TRIM(aisle), 'Unknown')

FROM
(
    SELECT *,
           ROW_NUMBER() OVER
           (
               PARTITION BY aisle_id
               ORDER BY aisle_id
           ) AS rn

    FROM bronze.aisles

    WHERE aisle_id IS NOT NULL

) t

WHERE rn = 1;

-- ============================================================================
-- STEP 5 : LOAD DEPARTMENTS
-- ============================================================================

INSERT INTO silver.departments

SELECT

    department_id,

    COALESCE(TRIM(department), 'Unknown')

FROM
(
    SELECT *,
           ROW_NUMBER() OVER
           (
               PARTITION BY department_id
               ORDER BY department_id
           ) AS rn

    FROM bronze.departments

    WHERE department_id IS NOT NULL

) t

WHERE rn = 1;

-- ============================================================================
-- STEP 6 : LOAD ORDER_PRODUCTS_PRIOR
-- ============================================================================

INSERT INTO silver.order_products_prior

SELECT

    order_id,

    product_id,

    CASE
        WHEN add_to_cart_order > 0
        THEN add_to_cart_order
        ELSE NULL
    END,

    CASE
        WHEN reordered IN (0,1)
        THEN reordered
        ELSE 0
    END

FROM bronze.order_products_prior

WHERE order_id IS NOT NULL;

-- ============================================================================
-- STEP 7 : LOAD ORDER_PRODUCTS_TRAIN
-- ============================================================================

INSERT INTO silver.order_products_train

SELECT

    order_id,

    product_id,

    CASE
        WHEN add_to_cart_order > 0
        THEN add_to_cart_order
        ELSE NULL
    END,

    CASE
        WHEN reordered IN (0,1)
        THEN reordered
        ELSE 0
    END

FROM bronze.order_products_train

WHERE order_id IS NOT NULL;

-- ============================================================================
-- END OF SILVER LAYER ETL
-- ============================================================================
