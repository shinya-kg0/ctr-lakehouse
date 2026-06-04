-- クリック数はインプレッション数を超えないはず
SELECT *
FROM {{ ref('gold_ctr_by_hour') }}
WHERE clicks > impressions
