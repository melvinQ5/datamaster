-- ���ƽ����Ǵ���
with t1 as (
select day_name ,full_date  ,dp.boxsku ,OrderNumber ,ifnull(istheme,'������Ʒ') istheme  ,ele_name_group ,dp.Quantity ,dp.Price
from daily_PurchaseOrder dp
join dim_date dd on date(dp.ordertime) = dd.full_date
join wt_products wp on dp.BoxSku =wp.BoxSku and wp.ProjectTeam='��ٻ�'
left join  ( select boxsku ,ele_name_group ,case when ele_name_group regexp '��ʥ��|ʥ����' then '����Ʒ'  end istheme from view_kbh_element ) t
on dp.BoxSku = t.boxsku
where OrderTime >= '2023-09-01' and OrderTime < '2023-11-30'
)

, t0 as (
select ifnull(istheme,'�ϼ�') �Ƿ����� ,count(distinct t1.BoxSku) �ɹ���SKU�� ,count(distinct OrderNumber) �ɹ��ܵ���
from t1 group by grouping sets ((),(istheme)) )

,day_name_stat as (
select �Ƿ�����
  ,avg(case when day_name = 'Monday' then sku_cnt end ) ��һƽ���ɹ�sku����
from ( select ifnull(istheme,'�ϼ�') �Ƿ����� ,day_name ,full_daste  ,count(distinct boxsku ) sku_cnt
from t1 group by day_name ,full_daste ,istheme ) tmp
group by grouping sets ((),(istheme)) )

select * from  day_name_stat