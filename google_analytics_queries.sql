CREATE DATABASE google_analytics;
USE google_analytics;

CREATE TABLE funnel (
  funnel_step VARCHAR(50),
  step_number INT,
  users INT
);

SELECT * FROM google_analytics.funnel;

CREATE TABLE traffic_sources (
  channel VARCHAR(50),
  total_users INT,
  purchasers INT,
  conversion_rate DECIMAL(5,2)
);

CREATE TABLE devices (
  device_type VARCHAR(50),
  total_users INT,
  purchasers INT,
  conversion_rate DECIMAL(5,2)
);

CREATE TABLE top_products (
  product_name VARCHAR(100),
  total_units_sold BIGINT,
  total_revenue DECIMAL(10,2),
  product_views INT,
  purchasers INT,
  view_to_purchase_rate DECIMAL(5,2)
);

CREATE TABLE monthly_trend (
  month VARCHAR(10),
  total_users INT,
  purchasers INT,
  total_revenue DECIMAL(10,2),
  conversion_rate DECIMAL(5,2)
);

SELECT * FROM google_analytics.traffic_sources;
SELECT * FROM google_analytics.devices;
SELECT * FROM google_analytics.top_products;
SELECT * FROM google_analytics.monthly_trend;

SELECT
  funnel_step,
  step_number,
  users,
  ROUND(users * 100.0 / MAX(users) OVER(), 1) AS pct_of_total,
  ROUND((users - LAG(users) OVER(ORDER BY step_number)) * 100.0 / 
    LAG(users) OVER(ORDER BY step_number), 1) AS dropoff_rate
FROM funnel
ORDER BY step_number;

SELECT
  channel,
  total_users,
  purchasers,
  conversion_rate,
  CASE
    WHEN channel = 'organic' THEN 'Organic Search'
    WHEN channel = 'cpc' THEN 'Paid Search'
    WHEN channel = 'referral' THEN 'Referral'
    WHEN channel = '(none)' THEN 'Direct'
    WHEN channel = '(data deleted)' THEN 'Privacy Protected'
    ELSE 'Other'
  END AS channel_label
FROM traffic_sources
ORDER BY total_users DESC;

CREATE VIEW traffic_sources_clean AS
SELECT
  channel,
  total_users,
  purchasers,
  conversion_rate,
  CASE
    WHEN channel = 'organic' THEN 'Organic Search'
    WHEN channel = 'cpc' THEN 'Paid Search'
    WHEN channel = 'referral' THEN 'Referral'
    WHEN channel = '(none)' THEN 'Direct'
    WHEN channel = '(data deleted)' THEN 'Privacy Protected'
    ELSE 'Other'
  END AS channel_label
FROM traffic_sources
ORDER BY total_users DESC;

CREATE VIEW funnel_clean AS
SELECT
  funnel_step,
  step_number,
  users,
  ROUND(users * 100.0 / MAX(users) OVER(), 1) AS pct_of_total,
  ROUND((users - LAG(users) OVER(ORDER BY step_number)) * 100.0 / 
    LAG(users) OVER(ORDER BY step_number), 1) AS dropoff_rate
FROM funnel
ORDER BY step_number;

CREATE VIEW devices_clean AS
SELECT
  device_type,
  total_users,
  purchasers,
  conversion_rate,
  ROUND(total_users * 100.0 / SUM(total_users) OVER(), 1) AS pct_of_traffic
FROM devices
ORDER BY total_users DESC;

CREATE VIEW products_clean AS
SELECT
  product_name,
  total_units_sold,
  total_revenue,
  product_views,
  purchasers,
  view_to_purchase_rate,
  CASE
    WHEN view_to_purchase_rate >= 3 THEN 'High Converter'
    WHEN view_to_purchase_rate >= 1.5 THEN 'Average Converter'
    ELSE 'Low Converter'
  END AS conversion_category
FROM top_products
WHERE total_units_sold < 1000000
ORDER BY total_revenue DESC;

CREATE VIEW monthly_trend_clean AS
SELECT
  month,
  total_users,
  purchasers,
  total_revenue,
  conversion_rate,
  ROUND((total_revenue - LAG(total_revenue) OVER(ORDER BY month)) * 100.0 /
    LAG(total_revenue) OVER(ORDER BY month), 1) AS revenue_growth
FROM monthly_trend
ORDER BY month;

SELECT * FROM funnel_clean;
SELECT * FROM traffic_sources_clean;
SELECT * FROM devices_clean;
SELECT * FROM products_clean;
SELECT * FROM monthly_trend_clean;