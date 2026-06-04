{{
    config(
        materialized='incremental',
        incremental_strategy='merge',
        unique_key='id',
        file_format='delta',
        location_root='s3://ctr-lakehouse-silver/dbt/'
    )
}}

SELECT
  id,
  click,
  hour_ts,
  C1,
  banner_pos,
  site_id,
  site_domain,
  site_category,
  app_id,
  app_domain,
  app_category,
  device_id,
  device_ip,
  device_model,
  device_type,
  device_conn_type,
  C14, C15, C16, C17, C18, C19, C20, C21
FROM delta.`s3://ctr-lakehouse-silver/delta/`

{% if is_incremental() %}
where hour_ts > (select max(hour_ts) from {{ this }})
{% endif %}
