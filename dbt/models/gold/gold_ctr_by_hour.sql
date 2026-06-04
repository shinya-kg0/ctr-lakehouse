{{
    config(
        materialized='table',
        file_format='delta',
        location_root='s3://ctr-lakehouse-gold/dbt/'
    )
}}

SELECT
  DATE_TRUNC('hour', hour_ts) as hour,
  count(*)                    as impressions, 
  sum(click)                  as clicks,
  round(sum(click) / count(*) * 100, 2) as ctr_pct
FROM {{ ref('silver_clicks') }}
GROUP BY 1
ORDER BY 1