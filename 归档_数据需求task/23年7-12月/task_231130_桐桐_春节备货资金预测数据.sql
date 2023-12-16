-- 已移交新星处理
with t1 as (
select day_name ,full_date  ,dp.boxsku ,OrderNumber ,ifnull(istheme,'非主题品') istheme  ,ele_name_group ,dp.Quantity ,dp.Price
from daily_PurchaseOrder dp
join dim_date dd on date(dp.ordertime) = dd.full_date
join wt_products wp on dp.BoxSku =wp.BoxSku and wp.ProjectTeam='快百货'
left join  ( select boxsku ,ele_name_group ,case when ele_name_group regexp '万圣节|圣诞节' then '主题品'  end istheme from view_kbh_element ) t
on dp.BoxSku = t.boxsku
where OrderTime >= '2023-09-01' and OrderTime < '2023-11-30'
)

, t0 as (
select ifnull(istheme,'合计') 是否主题 ,count(distinct t1.BoxSku) 采购总SKU数 ,count(distinct OrderNumber) 采购总单数
from t1 group by grouping sets ((),(istheme)) )

,day_name_stat as (
select 是否主题
  ,avg(case when day_name = 'Monday' then sku_cnt end ) 周一平均采购sku个数
from ( select ifnull(istheme,'合计') 是否主题 ,day_name ,full_daste  ,count(distinct boxsku ) sku_cnt
from t1 group by day_name ,full_daste ,istheme ) tmp
group by grouping sets ((),(istheme)) )

select * from  day_name_stat