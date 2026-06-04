-- hour_tsが正常な範囲内（2014年〜2015年）であること
SELECT *
FROM {{ ref('silver_clicks') }}
WHERE hour_ts < '2014-01-01'
   OR hour_ts > '2015-12-31'
