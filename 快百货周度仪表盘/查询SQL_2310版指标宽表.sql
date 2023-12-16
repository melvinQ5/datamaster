select concat(dimensionid,'销售额') 匹配列 ,'' 团队  ,'' 关键指标 , totalgross as 指标值
from ads_kbh_report_metrics
where  FirstDay='${StartDay}'
order by concat(dimensionid,'销售额')
