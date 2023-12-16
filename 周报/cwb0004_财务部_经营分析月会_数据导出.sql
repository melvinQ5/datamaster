
-- 导出数据
select handletime as 月份 , memo as 指标 , handlename as 部门 ,c4 + 0 as 指标值
from manual_table where c1 = '经营分析月会' 
and c2 =2023 and c3 = 11
and handlename != '深圳领科' 
and memo not regexp '新增退款|利润额|SkU总数量'  -- 剔除掉写错的指标名称
order by handletime  , memo ,handlename;