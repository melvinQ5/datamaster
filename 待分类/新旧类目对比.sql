/*
维度：销售部门+店铺+一级类目 ；销售部门+账号+一级类目
指标：销售额、销售额占比
分析：降序
map1 新系统类名excel 旧1级-新1级 
map2 产品类名表.旧1级中文-sku

 */

with 
new_sku_map as (
select * from JinqinSku js 
)

, map_categ as ( -- 新旧一级类目匹配关系
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


, orders as ( -- 表1 销售部门+店铺+一级类目
select 
	ms.AccountCode  -- 账号
	, ops.ShopIrobotId -- 店铺 
	, ms.department 
	, mc.categ_old
	, mc.categ_new
	, ops.BoxSku 
	, InCome
from OrderProfitSettle ops 
join import_data.mysql_store ms on ops.ShopIrobotId = ms.Code -- 关联mysql_store中有的店铺
left join map_categ mc on ops.BoxSku = mc.BoxSKU -- 关联产品类名表中最新的 sku与类目
where 
	ops.PayTime BETWEEN  '2022-04-01' and '2022-09-30'
	and ops.TransactionType = '付款'
	and ops.OrderStatus <> '作废'
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




