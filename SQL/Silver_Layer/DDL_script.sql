CREATE TABLE silver.aisles(
  aisle_id INT,
  aisle VARCHAR(255)
);

CREATE TABLE silver.departments(
  department_id INT,
  department VARCHAR(100)
);

CREATE TABLE silver.order_products_prior(
  order_id	INT,
  product_id	INT,
  add_to_cart_order INT,	
  reordered INT
);

CREATE TABLE silver.order_products_train(
  order_id	INT,
  product_id	INT,
  add_to_cart_order	INT,
  reordered INT
);

CREATE TABLE silver.orders(
  order_id	INT,
  user_id	INT,
  eval_set	VARCHAR(50),
  order_number	INT,
  order_dow	INT,
  order_hour_of_day INT,	
  days_since_prior_order INT
);

CREATE TABLE silver.products(
  product_id	INT ,
  product_name	VARCHAR(255),
  aisle_id	INT,
  department_id INT
);

-- Adding Two More Columns For later Transformation
ALTER TABLE silver.orders
ADD COLUMN order_day_name VARCHAR(20);
ALTER TABLE silver.orders
ADD COLUMN order_time_category VARCHAR(20);

