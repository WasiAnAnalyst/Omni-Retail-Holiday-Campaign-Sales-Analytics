CREATE VIEW top_products AS
WITH ProductRevenue AS (
    SELECT 
        p.category, 
        p.product_id, 
        SUM(ol.line_revenue) AS total_revenue
    FROM order_lines ol
    JOIN products p ON ol.product_id = p.product_id
    GROUP BY p.category, p.product_id
),
RankedProducts AS (
    SELECT 
        category, 
        product_id, 
        total_revenue,
        ROW_NUMBER() OVER (PARTITION BY category ORDER BY total_revenue DESC) as rank
    FROM ProductRevenue
)
SELECT category, product_id, total_revenue
FROM RankedProducts
WHERE rank = 1;