


select 
 concat(handlename,memo) as 匹配列
 ,handlename
 ,memo as 关键指标
 ,c2 as value
from manual_table where c1='快百货周报指标表' and handletime= '${StartDay}'
-- and memo = '旺款SPU数_主题_圣诞节'