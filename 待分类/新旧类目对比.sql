/*
ά�ȣ����۲���+����+һ����Ŀ �����۲���+�˺�+һ����Ŀ
ָ�꣺���۶���۶�ռ��
����������
map1 ��ϵͳ����excel ��1��-��1�� 
map2 ��Ʒ������.��1������-sku

 */

with 
new_sku_map as (
select * from JinqinSku js 
)

, map_categ as ( -- �¾�һ����Ŀƥ���ϵ
select 
	eppc.categ1 as categ_old
	, nsm.BoxSku as categ_new
	, epp.BoxSKU 
from 
	(
	select 
		split(CategoryPathByChineseName,'>')[1] as categ1
		, Id
	from import_data.erp_product_product_category 
	where IsDeleted = 0
	) eppc
join import_data.erp_product_products epp on eppc.Id = epp.ProductCategoryId  
left join new_sku_map nsm on eppc.categ1 = nsm.Sku
group by eppc.categ1 , categ_new , epp.BoxSKU 
)


, orders as ( -- ��1 ���۲���+����+һ����Ŀ
select 
	ms.AccountCode  -- �˺�
	, ops.ShopIrobotId -- ���� 
	, ms.department 
	, mc.categ_old
	, mc.categ_new
	, ops.BoxSku 
	, InCome
from OrderProfitSettle ops 
join import_data.mysql_store ms on ops.ShopIrobotId = ms.Code -- ����mysql_store���еĵ���
left join map_categ mc on ops.BoxSku = mc.BoxSKU -- ������Ʒ�����������µ� sku����Ŀ
where 
	ops.PayTime BETWEEN  '2022-04-01' and '2022-09-30'
	and ops.TransactionType = '����'
	and ops.OrderStatus <> '����'
	and ops.OrderPrice > 0
)


, shop_ranks as (
select 
	tmp1.*
	,round( categ_income / sum(categ_income) over(partition by ShopIrobotId),4) ShopIncome_rate
from 
	(
	select 
		AccountCode , ShopIrobotId , department , categ_new 
		, sum(InCome) as categ_income
	from orders 
	group by 
		AccountCode , ShopIrobotId , department , categ_new
	) tmp1
order by ShopIrobotId , ShopIncome_rate desc 
)

-- , account_ranks as (
select
	tmp1.*
	, round( categ_income / sum(categ_income) over(partition by AccountCode) ,4) AccountIncome_rate
from 
	(
	select 
		AccountCode , ShopIrobotId , department , categ_new
		, sum(InCome) as categ_income
	from orders 
	group by 
		AccountCode , ShopIrobotId , department , categ_new
	) tmp1
-- )




