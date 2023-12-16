/*
��ի��-ŷ��վ��
STEP1��ҵ����Աɸѡ-�����Ƿ�ǰ5�Ĺؼ���
STEP2��ɸѡ����Ʒ�������з��Ϲؼ��ʵ���Ʒ������ƷΪ�أ�
STEP3����7��Ա�ǰ7�충����������1���������������У�ȥ��ͣ����ȱ���Ĳ�Ʒ��
�����-ŷ��վ��ͬ��ի��
԰��-Ӣ��վ&����վ��ͬ��ի��
*/

with
ele as ( -- Ԫ��ӳ�����С������ SPU+SKU+NAME
select eppaea.spu ,eppaea.sku ,products.boxsku ,products.DevelopLastAuditTime
from import_data.erp_product_product_associated_element_attributes eppaea 
left join import_data.erp_product_product_element_attributes eppea on eppaea.ElementAttributeId = eppea.Id
left join import_data.erp_product_products products on eppaea.sku = products.sku 
where products.ismatrix = 0
group by eppaea.spu ,eppaea.sku ,products.boxsku ,products.DevelopLastAuditTime
)

,t_keyword_prod as (
select BoxSKU
from wt_products
where ProductName regexp '
���������|����ڹ���Ʒ|���츴���|����ͼƬ�����|����ڱ���ģ��|�������|����ڲʵ�|
�����|����|����|���ϳ���|Ƥ��ͧ���|Ƥ��ͧ������|����Ƥ��ͧ2��|Ƥ��ͧ����|
��ĸ����|��һ��ĸ�׽�����|Ůʿ��л����|ĸ�׽�����|��������|���������������|Ů�������������|�����װ��|ĸ�׽�װ��|
����ʽĸ�׽ڿ�|ĸ�׽���˱�|ĸ�׽ں��|ĸ�׽�����|ĸ�׽�Կ�׿�|ĸ�׽ڵ���װ��|��Ȥ��ĸ�׽ڿ�|
'
-- where ProductName regexp '
-- 	��������������|�����װ��|�����Ůʿװ��|���������|����ڻ���|�����ǵĸ���ڹ���Ʒ|�����ñ��|
-- ���������|����ڹ���Ʒ|���츴���|����ͼƬ�����|����ڱ���ģ��|�������|����ڲʵ�'	
-- where ProductName regexp '
-- 	ի��װ��Ʒ|ի������|ի�½��ٽ�����|ի�µ�|ի������|ի������|ի�±���ģ��|����װ��|��˹������|
-- 	ի�µ���|ի����ֽ|ի�²ʵ�|ի�´�|��ͯի������|ի�¼��²�|ի�²;�|��˹��ǽװ������|Ů����˹��ȹ��|
-- 	�����װ��|������������|����ڼ���|���������|������ǹ�|�����Ůʿװ��|����ںؿ�|
-- 	�����|�����װ��|����ڹ���Ʒ|���������|����ڲʵ�|�������|
-- 	����ֲ���|���ڻ���|С����|��԰Χ��װ��Ʒ|��ֲ��|��԰��Ҷ�ռ���|������Ҷ�Ļ�԰��'	
group by BoxSKU
)

,t_ord_trend as (
select pp.SKU ,pp.BoxSKU ,pp.ProductName ,pp.CategoryPathByChineseName,Cat1,c.ǰ7���Ʒ������,c.��7���Ʒ������,c.�������� 
from
	(select a.BoxSKU,number1 as '��7���Ʒ������',number2 as 'ǰ7���Ʒ������',number1-number2 as '��������' 
	from
		(
		select wo.boxsku
			,round(count(distinct PlatOrderNumber),2)  as  number1
		from import_data.wt_orderdetails wo 
		join import_data.mysql_store ms on wo.ShopCode =ms.Code and wo.IsDeleted = 0 
		join t_keyword_prod on wo.BoxSKU = t_keyword_prod.BoxSKU
-- 		join ( select spu ,BoxSku ,DevelopLastAuditTime from ele group by spu ,BoxSku ,DevelopLastAuditTime ) tmp 
-- 			on wo.BoxSku = tmp.boxsku -- ɸѡԪ��Ʒ
		where PayTime >=date_add('${NextStartday}',interval -7 day ) and PayTime <'${NextStartday}'
-- 		where PayTime >=date_add('${NextStartday}',interval -14 day ) and PayTime <'${NextStartday}'
		group by wo.boxsku 
		) as a
	inner join
		(
		select wo.boxsku
			,round(count(distinct PlatOrderNumber),2)  as  number2
		from import_data.wt_orderdetails wo 
		join import_data.mysql_store ms on wo.ShopCode =ms.Code and wo.IsDeleted = 0 
		join t_keyword_prod on wo.BoxSKU = t_keyword_prod.BoxSKU
-- 		join ( select spu ,BoxSku ,DevelopLastAuditTime from ele group by spu ,BoxSku ,DevelopLastAuditTime ) tmp 
-- 			on wo.BoxSku = tmp.boxsku -- ɸѡԪ��Ʒ
		where PayTime >=date_add('${NextStartday}',interval -14 day ) and PayTime <date_add('${NextStartday}',interval -7 day )
-- 		where PayTime >=date_add('${NextStartday}',interval -28 day ) and PayTime <date_add('${NextStartday}',interval -14 day )
		group by wo.boxsku 
		) as b
	on a.BoxSKU=b.BoxSKU 
-- 	and number1-number2>=1
	) as c
left join wt_products as pp
on c.BoxSKU=pp.BoxSKU
and IsDeleted=0
and ProductStatus not in ('2','4')
)

select *
from t_ord_trend  where boxsku is not null
order by �������� desc limit 200