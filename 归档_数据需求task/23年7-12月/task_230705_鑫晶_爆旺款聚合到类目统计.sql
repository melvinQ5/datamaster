-- 类目聚合
-- with a as (
-- select dkpl.* ,cat1 ,cat2 ,cat3 ,cat4 
-- from dep_kbh_product_level dkpl 
-- left join ( select spu ,cat1 ,cat2 ,cat3 ,cat4 from wt_products group by spu ,cat1 ,cat2 ,cat3 ,cat4   ) t 
-- on dkpl.spu =t.spu 
-- where FirstDay = '2023-06-01' and Department = '快百货泉州'
-- )
-- 
-- 
-- select 
-- 	case 
-- 		when concat(prod_level ,cat1 ,cat2 ,cat3 ,cat4) is not null  then  '1-4级' 
-- 		when concat(prod_level ,cat1 ,cat2 ,cat3) is not null and coalesce(cat4) is null then  '1-3级' 
-- 		when concat(prod_level ,cat1 ,cat2 ) is not null and coalesce(cat3, cat4) is null then  '1-2级' 
-- 		when concat(prod_level ,cat1 ) is not null and coalesce(cat2 ,cat3 ,cat4) is null then  '1级' 
-- 		end as `预置分析维度`
-- 	,prod_level ,cat1 ,cat2 ,cat3 ,cat4  
-- 	,sum(sales_in30d ) 销售额
-- 	,sum(profit_in30d ) 利润额
-- 	,round( sum(profit_in30d ) / sum(sales_in30d ) ,4) 利润率
-- from a 	
-- group by grouping sets (
-- 	(prod_level ,cat1 ,cat2 ,cat3 ,cat4 ),
-- 	(prod_level ,cat1 ,cat2 ,cat3 ),
-- 	(prod_level ,cat1 ,cat2 ), 
-- 	(prod_level ,cat1  ) )

	
-- SPU清单	

select 
FirstDay 统计时间
,Department 
,dkpl.spu 
,prod_level 
,cat1 ,cat2 ,cat3 ,cat4 
,sales_in30d 销售额
,profit_in30d 利润额_未扣广告
,round( profit_in30d  / sales_in30d ,4) 利润率
from dep_kbh_product_level dkpl 
left join ( select spu ,cat1 ,cat2 ,cat3 ,cat4 from wt_products group by spu ,cat1 ,cat2 ,cat3 ,cat4   ) t 
on dkpl.spu =t.spu 
where right(FirstDay,3) = '-01' and Department = '快百货泉州' and prod_level regexp '爆|旺'
order by spu,统计时间



	
	