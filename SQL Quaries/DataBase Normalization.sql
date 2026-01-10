SELECT * FROM order_lines;

ALTER TABLE order_lines 
RENAME COLUMN "OrderLineID" TO orderline_id;


ALTER TABLE order_lines 
RENAME COLUMN "OrderID" TO order_id;


ALTER TABLE order_lines 
RENAME COLUMN "ProductID" TO product_id;


ALTER TABLE order_lines 
RENAME COLUMN "Qty" TO quantity;


ALTER TABLE order_lines 
RENAME COLUMN "UnitPrice" TO unit_price;


ALTER TABLE order_lines 
RENAME COLUMN "LineDiscount" TO line_discount;


ALTER TABLE order_lines 
RENAME COLUMN "LineCost" TO line_cost;


ALTER TABLE order_lines 
RENAME COLUMN "LineRevenue" TO line_revenue;


SELECT 
    quantity, 
    unit_price, 
    line_discount, 
    line_cost,
	line_revenue
FROM order_lines 
LIMIT 5;



ALTER TABLE order_lines 
    ALTER COLUMN unit_price TYPE numeric,
    ALTER COLUMN line_cost TYPE numeric,
    ALTER COLUMN line_revenue TYPE numeric,
    ALTER COLUMN line_discount TYPE numeric;



UPDATE order_lines
SET 
unit_price = NULLIF(regexp_replace(unit_price::text, '[^0-9.]', '', 'g'), '')::numeric,
line_cost = NULLIF(regexp_replace(line_cost::text, '[^0-9.]', '', 'g'), '')::numeric,
line_revenue = NULLIF(regexp_replace(line_revenue::text, '[^0-9.]', '', 'g'), '')::numeric,
line_discount = NULLIF(regexp_replace(line_discount::text, '[^0-9.]', '', 'g'), '')::numeric;


UPDATE order_lines
SET order_id =TRIM(order_id);

UPDATE order_lines
SET orderline_id =TRIM(orderline_id);

UPDATE order_lines
SET product_id =TRIM(product_id);



SELECT * FROM orders;


ALTER TABLE orders 
RENAME COLUMN "OrderID" TO order_id;


ALTER TABLE orders 
RENAME COLUMN "OrderID" TO order_id;


ALTER TABLE orders 
RENAME COLUMN "OrderDateTime" TO order_date;


ALTER TABLE orders
    ALTER COLUMN order_date TYPE DATE 
    USING order_date::DATE;

ALTER TABLE orders
RENAME COLUMN "CustomerID" TO customer_Id;


ALTER TABLE orders
RENAME COLUMN "ChannelID" TO channel_id;

ALTER TABLE orders
RENAME COLUMN "StoreID" TO store_id;


ALTER TABLE orders
RENAME COLUMN "PromotionID" TO promotion_id;


ALTER TABLE orders
RENAME COLUMN "CouponCode" TO coupon_code;


ALTER TABLE orders
RENAME COLUMN "PaymentType" TO payment_type;


SELECT * FROM orders;





SELECT * FROM fullfilment;

ALTER TABLE fullfilment RENAME COLUMN "ShipmentID" TO shipment_id;
ALTER TABLE fullfilment RENAME COLUMN "OrderID" TO order_id;
ALTER TABLE fullfilment RENAME COLUMN "WarehouseID" TO warehouse_id;
ALTER TABLE fullfilment RENAME COLUMN "Carrier" TO carrier;
ALTER TABLE fullfilment RENAME COLUMN "ServiceLevel" TO service_level;
ALTER TABLE fullfilment RENAME COLUMN "PromisedDate" TO promised_date;
ALTER TABLE fullfilment RENAME COLUMN "ShipDate" TO ship_date;
ALTER TABLE fullfilment RENAME COLUMN "DeliveryDate" TO delivery_date;
ALTER TABLE fullfilment RENAME COLUMN "ShipCost" TO ship_cost;
ALTER TABLE fullfilment RENAME COLUMN "DeliveryStatus" TO delivery_status;


SELECT * FROM fullfilment;

ALTER TABLE fullfilment
    ALTER COLUMN promised_date TYPE DATE 
    USING promised_date::DATE;



ALTER TABLE fullfilment
    ALTER COLUMN ship_date TYPE DATE 
    USING ship_date::DATE;



ALTER TABLE fullfilment
    ALTER COLUMN delivery_date TYPE DATE 
    USING delivery_date::DATE;



ALTER TABLE fullfilment
    ALTER COLUMN ship_cost TYPE numeric;




SELECT * FROM products;



ALTER TABLE products RENAME COLUMN "ProductID" TO product_id;
ALTER TABLE products RENAME COLUMN "Category" TO category;
ALTER TABLE products RENAME COLUMN "Subcategory" TO subcategory;
ALTER TABLE products RENAME COLUMN "StandardCost" TO standard_cost;
ALTER TABLE products RENAME COLUMN "MSRP" TO msrp;
ALTER TABLE products RENAME COLUMN "Vendor" TO vendor;
ALTER TABLE products RENAME COLUMN "SeasonalityTag" TO seasonality_tag;



ALTER TABLE products 
    ALTER COLUMN standard_cost TYPE numeric USING standard_cost::numeric,
    ALTER COLUMN msrp TYPE numeric USING msrp::numeric;

   
SELECT * FROM promotions;



ALTER TABLE promotions RENAME COLUMN "PromotionID" TO promotion_id;
ALTER TABLE promotions RENAME COLUMN "Name" TO name;
ALTER TABLE promotions RENAME COLUMN "CampaignType" TO campaign_type;
ALTER TABLE promotions RENAME COLUMN "StartDate" TO start_date;
ALTER TABLE promotions RENAME COLUMN "EndDate" TO end_date;
ALTER TABLE promotions RENAME COLUMN "TargetSegment" TO target_segment;
ALTER TABLE promotions RENAME COLUMN "DiscountType" TO discount_type;
ALTER TABLE promotions RENAME COLUMN "PlannedLift" TO planned_lift_percent;
ALTER TABLE promotions RENAME COLUMN "PlannedBudget" TO planned_budget;


UPDATE promotions
SET planned_budget = regexp_replace(planned_budget, '[^0-9.]', '', 'g')::numeric;


ALTER TABLE promotions 
    ALTER COLUMN start_date TYPE DATE USING start_date::DATE,
    ALTER COLUMN end_date TYPE DATE USING end_date::DATE,
    ALTER COLUMN planned_lift_percent TYPE NUMERIC USING planned_lift_percent::NUMERIC,
    ALTER COLUMN planned_budget TYPE NUMERIC USING planned_budget::NUMERIC;


SELECT * FROM returns;



ALTER TABLE returns RENAME COLUMN "ReturnID" TO return_id;
ALTER TABLE returns RENAME COLUMN "OrderLineID" TO orderline_id;
ALTER TABLE returns RENAME COLUMN "ReturnDate" TO return_date;
ALTER TABLE returns RENAME COLUMN "ReasonCode" TO reason_code;
ALTER TABLE returns RENAME COLUMN "Condition" TO condition;
ALTER TABLE returns RENAME COLUMN "Refund" TO refund_amount;
ALTER TABLE returns RENAME COLUMN "RestockFee" TO restock_fee;
ALTER TABLE returns RENAME COLUMN "ReturnShipCost" TO return_ship_cost;
ALTER TABLE returns RENAME COLUMN "Disposition" TO disposition;




-- Step 1: Clean and Convert to Numeric/Date
ALTER TABLE returns 
    ALTER COLUMN return_date TYPE DATE USING return_date::DATE,
    ALTER COLUMN refund_amount TYPE NUMERIC USING (regexp_replace(refund_amount::text, '[^0-9.]', '', 'g'))::NUMERIC,
    ALTER COLUMN restock_fee TYPE NUMERIC USING (regexp_replace(restock_fee::text, '[^0-9.]', '', 'g'))::NUMERIC,
    ALTER COLUMN return_ship_cost TYPE NUMERIC USING (regexp_replace(return_ship_cost::text, '[^0-9.]', '', 'g'))::NUMERIC;




SELECT * FROM returns;


SELECT * FROM calendar;


ALTER TABLE calendar RENAME TO dim_date;


SELECT * FROM dim_date;


ALTER TABLE dim_date RENAME COLUMN "Date" TO date;


ALTER TABLE dim_date 
    ALTER COLUMN date TYPE DATE USING date::DATE;



---Primary keys
-- Dim Date
ALTER TABLE dim_date ADD PRIMARY KEY (date_key);

-- Products
ALTER TABLE products ADD PRIMARY KEY (product_id);

-- Promotions
ALTER TABLE promotions ADD PRIMARY KEY (promotion_id);

-- Header Orders
ALTER TABLE orders ADD PRIMARY KEY (order_id);
---returns
ALTER TABLE order_lines 
ADD PRIMARY KEY (orderline_id);



---Foreign keys
-- Link order_lines to the orders table
ALTER TABLE order_lines 
ADD CONSTRAINT fk_orders
FOREIGN KEY (order_id) REFERENCES orders(order_id);

-- Link order_lines to Products
ALTER TABLE order_lines 
ADD CONSTRAINT fk_order_products 
FOREIGN KEY (product_id) REFERENCES products(product_id);



-- Link shipments to orders
ALTER TABLE fullfilment 
ADD CONSTRAINT fk_shipment_order 
FOREIGN KEY (order_id) REFERENCES orders(order_id);

-- Link returns to the specific line item
ALTER TABLE returns 
ADD CONSTRAINT fk_return_line 
FOREIGN KEY (orderline_id) REFERENCES order_lines(orderline_id);



SELECT * FROM promotions;





INSERT INTO promotions (
    promotion_id,
    Name,
    CampaignType,
    StartDate,
    EndDate,
    TargetSegment,
    DiscountType,
    "PlannedLift%",
    PlannedBudget
)
VALUES (
    0,
    'No Promotion',
    'NONE',
    DATE '2000-01-01',
    DATE '2099-12-31',
    'ALL',
    'NONE',
    0,
    0
);




CREATE TABLE orders_repair (
    order_id TEXT,
    customer_id TEXT
    -- (You only need these two columns for the fix)
);


SELECT current_database();


---fillup the dim_date
ALTER TABLE dim_date RENAME COLUMN "Week" TO week;



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


SELECT * FROM dim_date 
WHERE date BETWEEN '2026-01-06' AND '2026-02-11'
ORDER BY date ASC;

