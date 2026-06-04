select *
from {{ ref('gold_ctr_by_hour')}}
where ctr_pct < 0 or ctr_pct > 100
