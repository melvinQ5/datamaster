-- ��Ŀ�ۺ�
-- with a as (
-- select dkpl.* ,cat1 ,cat2 ,cat3 ,cat4 
-- from dep_kbh_product_level dkpl 
-- left join ( select spu ,cat1 ,cat2 ,cat3 ,cat4 from wt_products group by spu ,cat1 ,cat2 ,cat3 ,cat4   ) t 
-- on dkpl.spu =t.spu 
-- where FirstDay = '2023-06-01' and Department = '��ٻ�Ȫ��'
-- )
-- 
-- 
-- select 
-- 	case 
-- 		when concat(prod_level ,cat1 ,cat2 ,cat3 ,cat4) is not null  then  '1-4��' 
-- 		when concat(prod_level ,cat1 ,cat2 ,cat3) is not null and coalesce(cat4) is null then  '1-3��' 
-- 		when concat(prod_level ,cat1 ,cat2 ) is not null and coalesce(cat3, cat4) is null then  '1-2��' 
-- 		when concat(prod_level ,cat1 ) is not null and coalesce(cat2 ,cat3 ,cat4) is null then  '1��' 
-- 		end as `Ԥ�÷���ά��`
-- 	,prod_level ,cat1 ,cat2 ,cat3 ,cat4  
-- 	,sum(sales_in30d ) ���۶�
-- 	,sum(profit_in30d ) �����
-- 	,round( sum(profit_in30d ) / sum(sales_in30d ) ,4) ������
-- from a 	
-- group by grouping sets (
-- 	(prod_level ,cat1 ,cat2 ,cat3 ,cat4 ),
-- 	(prod_level ,cat1 ,cat2 ,cat3 ),
-- 	(prod_level ,cat1 ,cat2 ), 
-- 	(prod_level ,cat1  ) )

	
-- SPU�嵥	

select 
FirstDay ͳ��ʱ��
,Department 
,dkpl.spu 
,prod_level 
,cat1 ,cat2 ,cat3 ,cat4 
,sales_in30d ���۶�
,profit_in30d �����_δ�۹��
,round( profit_in30d  / sales_in30d ,4) ������
from dep_kbh_product_level dkpl 
left join ( select spu ,cat1 ,cat2 ,cat3 ,cat4 from wt_products group by spu ,cat1 ,cat2 ,cat3 ,cat4   ) t 
on dkpl.spu =t.spu 
where right(FirstDay,3) = '-01' and Department = '��ٻ�Ȫ��' and prod_level regexp '��|��'
order by spu,ͳ��ʱ��



	
	