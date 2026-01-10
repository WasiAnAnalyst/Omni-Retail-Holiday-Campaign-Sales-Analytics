---Data cleaning & Validation on order_lines Table
SELECT * FROM order_lines;

---Null values Check
SELECT 
    SUM(CASE WHEN orderline_id IS NULL THEN 1 ELSE 0 END) AS null_orderline_id,
    SUM(CASE WHEN order_id IS NULL THEN 1 ELSE 0 END) AS null_order_id,
    SUM(CASE WHEN product_id IS NULL THEN 1 ELSE 0 END) AS null_quantity,
    SUM(CASE WHEN quantity IS NULL THEN 1 ELSE 0 END) AS null_unit_price,
    SUM(CASE WHEN unit_price IS NULL THEN 1 ELSE 0 END) AS null_location,
    SUM(CASE WHEN line_discount IS NULL THEN 1 ELSE 0 END) AS null_line_discount,
    SUM(CASE WHEN line_cost IS NULL THEN 1 ELSE 0 END) AS null_line_cost,
    SUM(CASE WHEN line_revenue IS NULL THEN 1 ELSE 0 END) AS null_line_revenue
FROM order_lines;



---Duplicate Row Check
SELECT 
orderline_id,
order_id,
product_id,
quantity,
unit_price,
line_discount,
line_cost,
line_revenue,
COUNT(*) AS "CNT"
FROM order_lines
GROUP BY
orderline_id,
order_id,
product_id,
quantity,
unit_price,
line_discount,
line_cost,
line_revenue
HAVING COUNT(*)>1;


---Quantity Logic
SELECT * FROM order_lines
WHERE quantity <=0;


---validation
SELECT 
product_id,
MAX(quantity) AS max_quantity,
MIN(quantity) AS min_quantity,
SUM(line_revenue) AS total_revenue
FROM order_lines 
GROUP BY product_id;


---all orderline_id should be uniqe
SELECT orderline_id, COUNT(*)
FROM order_lines
GROUP BY orderline_id
HAVING COUNT(*) > 1;

---Product Validations
SELECT DISTINCT 
    lo.product_id AS missing_product_id
FROM order_lines lo
LEFT JOIN products p ON lo.product_id = p.product_id
WHERE p.product_id IS NULL;



---
---order_id Validation
SELECT DISTINCT lo.order_id
from order_lines lo
LEFT JOIN orders o ON lo.order_id = o.order_id
WHERE o.order_id IS NULL;



---Data cleaning & Validation on orders Table
SELECT * FROM orders;

---Null Check
SELECT 
    SUM(CASE WHEN order_id IS NULL THEN 1 ELSE 0 END) AS null_order_id,
    SUM(CASE WHEN order_date IS NULL THEN 1 ELSE 0 END) AS null_order_date,
    SUM(CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END) AS null_customer_id,
    SUM(CASE WHEN channel_id IS NULL THEN 1 ELSE 0 END) AS null_channel_id,
    SUM(CASE WHEN store_id IS NULL THEN 1 ELSE 0 END) AS null_store_id,
    SUM(CASE WHEN promotion_id IS NULL THEN 1 ELSE 0 END) AS null_promotion_id,
    SUM(CASE WHEN coupon_code IS NULL THEN 1 ELSE 0 END) AS null_coupon_code,
    SUM(CASE WHEN payment_type IS NULL THEN 1 ELSE 0 END) AS null_payment_type
FROM orders;

---fixing null in store_id Column
SELECT 
channel_id, 
COUNT(*) AS total_orders,
COUNT(store_id) AS non_null_stores,
SUM(CASE WHEN store_id IS NULL THEN 1 ELSE 0 END) AS null_store_count
FROM orders
GROUP BY channel_id;



UPDATE orders
SET channel_id = CASE 
    WHEN channel_id = 'WEB' THEN 'Website'
    WHEN channel_id = 'MKT' THEN 'Marketplace'
    WHEN channel_id = 'STORE' THEN 'Store'
    ELSE channel_id 
END;


UPDATE orders
SET store_id = CASE 
    WHEN channel_id = 'Website' THEN 'Website'
    WHEN channel_id = 'Marketplace' THEN 'Marketplace'
END
WHERE store_id IS NULL;---fixed

---(for check the promotion_code we need to clarify promotions table are valid)
SELECT * FROM promotions;
SELECT 
    promotion_id, 
    name,
	campaign_type,
	start_date,
	end_date,
	target_segment,
	discount_type,
	planned_lift_percent,
	planned_budget,
	COUNT(*) AS "CNT"
	FROM promotions
	GROUP BY promotion_id, 
    name,
	campaign_type,
	start_date,
	end_date,
	target_segment,
	discount_type,
	planned_lift_percent,
	planned_budget
	HAVING COUNT(*) >1;
	
---end date < start_date
SELECT 
    start_date,
    end_date
FROM promotions
WHERE end_date < start_date;



---fixing the null_promotion_id in orders table
INSERT INTO promotions (
    promotion_id, 
    name, 
    campaign_type, 
    start_date, 
    end_date, 
    target_segment, 
    discount_type, 
    planned_lift_percent, 
    planned_budget
)
VALUES (
    'NO PROMO',              -- Or a text code like 'NOPROMO'
    'No Promotion', 
    'Standard Sale', 
    '2000-01-01',     -- A date in the far past
    '2099-12-31',     -- A date in the far future
    'All Customers', 
    'None', 
    0, 
    0
);


SELECT * FROM promotions;

 
--fix the null_promotion_id by NO PROMO
UPDATE orders 
SET promotion_id = 'NO PROMO' 
WHERE promotion_id IS NULL;



---fix the null_coupon_code
UPDATE orders
SET coupon_code = 'No COUPON'
WHERE coupon_code IS NULL;



---final null check
SELECT 
    SUM(CASE WHEN order_id IS NULL THEN 1 ELSE 0 END) AS null_order_id,
    SUM(CASE WHEN order_date IS NULL THEN 1 ELSE 0 END) AS null_order_date,
    SUM(CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END) AS null_customer_id,
    SUM(CASE WHEN channel_id IS NULL THEN 1 ELSE 0 END) AS null_channel_id,
    SUM(CASE WHEN store_id IS NULL THEN 1 ELSE 0 END) AS null_store_id,
    SUM(CASE WHEN promotion_id IS NULL THEN 1 ELSE 0 END) AS null_promotion_id,
    SUM(CASE WHEN coupon_code IS NULL THEN 1 ELSE 0 END) AS null_coupon_code,
    SUM(CASE WHEN payment_type IS NULL THEN 1 ELSE 0 END) AS null_payment_type
FROM orders;



---Duplicate order_id check
SELECT order_id, COUNT(*) AS occurrence_count
FROM orders
GROUP BY order_id
HAVING COUNT(*) > 1;


---payment type validation
SELECT payment_type
FROM orders
GROUP  BY payment_type;


UPDATE orders
SET payment_type =INITCAP(payment_type);


---TRIM
UPDATE orders
SET payment_type =TRIM(payment_type);



---promotion validation
SELECT DISTINCT o.promotion_id
FROM orders o  
LEFT JOIN promotions p ON o.promotion_id = p.promotion_id
WHERE p.promotion_id IS NULL 
  AND o.promotion_id IS NOT NULL;


---order_date >current_dae
 SELECT *
FROM orders
WHERE order_date > CURRENT_DATE;




---data cleaning & validations on fullfilment table
SELECT * FROM fullfilment;

---null values check
SELECT 
    SUM(CASE WHEN shipment_id IS NULL THEN 1 ELSE 0 END) AS null_shipment_id,
    SUM(CASE WHEN order_id IS NULL THEN 1 ELSE 0 END) AS null_order_id,
    SUM(CASE WHEN warehouse_id IS NULL THEN 1 ELSE 0 END) AS null_warehouse_id,
    SUM(CASE WHEN carrier IS NULL THEN 1 ELSE 0 END) AS null_carrier,
    SUM(CASE WHEN service_level IS NULL THEN 1 ELSE 0 END) AS null_service_level,
    SUM(CASE WHEN promised_date IS NULL THEN 1 ELSE 0 END) AS null_promised_date,
    SUM(CASE WHEN ship_date IS NULL THEN 1 ELSE 0 END) AS null_ship_date,
    SUM(CASE WHEN delivery_date IS NULL THEN 1 ELSE 0 END) AS null_delivery_date,
    SUM(CASE WHEN ship_cost IS NULL THEN 1 ELSE 0 END) AS null_ship_cost,
	SUM(CASE WHEN delivery_status IS NULL THEN 1 ELSE 0 END) AS null_delvery_status
FROM fullfilment;



---duplicate Row check
SELECT shipment_id,
order_id,
warehouse_id,
carrier,
service_level,
promised_date,
ship_date,
delivery_date,
ship_cost,
delivery_status,
COUNT(*) AS "CNT"
FROM fullfilment
GROUP BY shipment_id,
order_id,
warehouse_id,
carrier,
service_level,
promised_date,
ship_date,
delivery_date,
ship_cost,
delivery_status
HAVING COUNT(*) >1;



---duplicate shipment_id check
SELECT shipment_id, COUNT(*) AS total_count
FROM fullfilment
GROUP BY shipment_id
HAVING COUNT(*) > 1;


---orphened orders
SELECT f.order_id
FROM fullfilment f
LEFT JOIN orders o ON f.order_id = o.order_id
WHERE o.order_id IS NULL;


SELECT * FROM fullfilment;


---service level validation
SELECT service_level
FROM fullfilment
GROUP BY service_level;



---date validation
SELECT 
    f.order_id, 
    o.order_date, 
    f.ship_date, 
    f.delivery_date
FROM fullfilment f
JOIN orders o ON f.order_id = o.order_id
WHERE f.ship_date > f.delivery_date  -- Shipped after it was delivered (Impossible)
   OR o.order_date > f.ship_date;    -- Ordered after it was shipped (Impossible)



---promise date validation
SELECT f.order_id, o.order_date, f.promised_date
FROM fullfilment f
JOIN orders o ON f.order_id = o.order_id
WHERE f.promised_date < o.order_date;



---delivary status
SELECT delivery_status
FROM fullfilment
GROUP BY delivery_status;


---warehouse check
SELECT warehouse_id
FROM fullfilment
GROUP BY warehouse_id;







---Data cleaning & validation on returns table
SELECT * FROM returns;


---null value check
SELECT 
    SUM(CASE WHEN return_id IS NULL THEN 1 ELSE 0 END) AS null_return_id,
    SUM(CASE WHEN orderline_id IS NULL THEN 1 ELSE 0 END) AS null_orderline_id,
    SUM(CASE WHEN return_date IS NULL THEN 1 ELSE 0 END) AS null_return_date,
    SUM(CASE WHEN reason_code IS NULL THEN 1 ELSE 0 END) AS null_reason_code,
    SUM(CASE WHEN condition  IS NULL THEN 1 ELSE 0 END) AS null_condition,
    SUM(CASE WHEN refund_amount IS NULL THEN 1 ELSE 0 END) AS null_refund_amount,
    SUM(CASE WHEN restock_fee IS NULL THEN 1 ELSE 0 END) AS null_restock_fee,
    SUM(CASE WHEN return_ship_cost IS NULL THEN 1 ELSE 0 END) AS null_return_ship_cost,
    SUM(CASE WHEN disposition IS NULL THEN 1 ELSE 0 END) AS null_disposition
	FROM returns;



---duplicate row checks
SELECT return_id,
orderline_id,
return_date,
reason_code,
condition,
refund_amount,
restock_fee,
return_ship_cost,
disposition,
COUNT(*) AS "CNT"
FROM returns
GROUP BY
return_id,
orderline_id,
return_date,
reason_code,
condition,
refund_amount,
restock_fee,
return_ship_cost,
disposition
HAVING COUNT(*) >1;




---return_date >order_date
SELECT r.return_id, o.order_id, o.order_date, r.return_date
FROM returns r
JOIN order_lines ol ON r.orderline_id = ol.orderline_id
JOIN orders o ON ol.order_id = o.order_id
WHERE r.return_date < o.order_date;


---negetive refund
SELECT * FROM returns 
WHERE refund_amount < 0 
   OR restock_fee < 0 
   OR return_ship_cost < 0;



---finencial validation
SELECT r.return_id,
r.orderline_id,
ol.line_revenue AS "total_price",
r.refund_amount,
r.restock_fee,
(r.refund_amount + r.restock_fee) AS "total_refunded_value",
(ol.line_revenue-(r.refund_amount + r.restock_fee)) AS "varience"
FROM returns r
JOIN order_lines ol ON r.orderline_id = ol.orderline_id
WhERE (r.refund_amount + r.restock_fee) > ol.line_revenue;


---investigating the 88 rows
SELECT 
    r.return_id,
    ol.line_revenue,
    (r.refund_amount + r.restock_fee) AS total_refund,
    (ol.line_revenue - (r.refund_amount + r.restock_fee)) AS variance
FROM returns r
JOIN order_lines ol ON r.orderline_id = ol.orderline_id
WHERE (r.refund_amount + r.restock_fee) > ol.line_revenue
ORDER BY variance ASC -- This puts the most negative (worst) numbers at the top
LIMIT 10;



SELECT 
    r.return_id,
    ol.line_revenue,
    r.refund_amount,
    r.return_ship_cost,
    (ol.line_revenue - r.refund_amount) AS price_diff
FROM returns r
JOIN order_lines ol ON r.orderline_id = ol.orderline_id
WHERE (r.refund_amount + r.restock_fee) > ol.line_revenue
LIMIT 10;



SELECT 
    r.return_id,
    ol.line_revenue AS "item_price",
    r.restock_fee,
    r.return_ship_cost,
    (r.restock_fee - ol.line_revenue) AS "fee_overage"
FROM returns r
JOIN order_lines ol ON r.orderline_id = ol.orderline_id
WHERE r.restock_fee > ol.line_revenue;

---the RESULT-------------
---restock_fee is makes more loses then the product_revenue



---disposition & condition validation
SELECT disposition
FROM returns
GROUP BY disposition;

SELECT condition
from returns
GROUP BY condition;


SELECT condition, disposition, COUNT(*) as total_items
FROM returns
GROUP BY condition, disposition
ORDER BY total_items DESC;




---reason-code
SELECT reason_code
FROM returns
GROUP BY reason_code;


---refund_date validation
SELECT MIN(return_date) AS"min_date",
MAX(return_date) AS "max_date"
FROM returns;




---date cleaning & validation on products table
SELECT * FROM products;

---null checks
SELECT 
    SUM(CASE WHEN product_id IS NULL THEN 1 ELSE 0 END) AS null_product_id,
    SUM(CASE WHEN category IS NULL THEN 1 ELSE 0 END) AS null_category,
    SUM(CASE WHEN subcategory IS NULL THEN 1 ELSE 0 END) AS null_subcategory,
    SUM(CASE WHEN standard_cost IS NULL THEN 1 ELSE 0 END) AS null_standard_cost,
    SUM(CASE WHEN msrp IS NULL THEN 1 ELSE 0 END) AS null_msrp,
    SUM(CASE WHEN vendor IS NULL THEN 1 ELSE 0 END) AS null_cvendor,
    SUM(CASE WHEN seasonality_tag IS NULL THEN 1 ELSE 0 END) AS null_seasonality_tag
FROM products;



---dim_date
SELECT * FROM dim_date;

---Min &  MAX date
SELECT MIN(date) AS "min_date",
MAX(date) AS "max_date"
FROM dim_date;


--date key condition
SELECT * FROM dim_date 
ORDER BY date_key ASC 
LIMIT 10;



--order_date validation
SELECT DISTINCT 
    o.order_date
FROM orders o 
LEFT JOIN dim_date d ON o.order_date = d.date
WHERE d.date IS NULL; 


---return_date validation
SELECT DISTINCT 
    r.return_date
FROM returns r 
LEFT JOIN dim_date d ON r.return_date = d.date
WHERE d.date IS NULL; 


---investigating those 37 values
SELECT DISTINCT 
    r.return_date
FROM returns r 
LEFT JOIN dim_date d ON r.return_date = d.date
WHERE d.date IS NULL
ORDER BY r.return_date ASC;


---insert those 37 rows on dim_date
INSERT INTO dim_date (date_key, date, week, fiscal_month, holiday_flag, event_name)
SELECT 
    -- This creates the ID (e.g., 20260106) to satisfy the NOT NULL constraint
    CAST(TO_CHAR(datum, 'YYYYMMDD') AS INT) AS date_key,
    datum::DATE AS date,
    EXTRACT(WEEK FROM datum) AS week,
    EXTRACT(MONTH FROM datum) AS fiscal_month,
    FALSE AS holiday_flag,
    NULL AS event_name
FROM generate_series(
    '2026-01-06'::DATE, 
    '2026-02-11'::DATE, 
    '1 day'::interval
) AS datum;



---event_name validation
SELECT event_name
FROM dim_date
group by event_name;



