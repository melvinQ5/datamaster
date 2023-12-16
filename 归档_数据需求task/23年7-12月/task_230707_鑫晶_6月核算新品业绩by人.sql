-- 定义：终审时间在23年3月1号及以后的产品，在4-6月的业绩贡献，每天更新付款时间=昨天的业绩数据
-- 


with 
t_prod as ( -- 230301后终审
select SKU ,SPU ,DATE_ADD(DevelopLastAuditTime,interval - 8 hour) as DevelopLastAuditTime 
	,de.name 
from import_data.erp_product_products epp 
left join (
	select case when sku = '李琴' then '李琴1688' else sku end  as name
	,boxsku as department
	,case when spu = '商品组' then '泉州商品组' when sku='郑燕飞' then '泉州商品组' else '成都商品组' end as dep2
	from JinqinSku js where Monday= '2023-03-31'
	) de
	on epp.DevelopUserName = de.name
where DATE_ADD(DevelopLastAuditTime,interval - 8 hour)  >= '2023-04-01' 
and  DATE_ADD(DevelopLastAuditTime,interval - 8 hour) < '2023-07-01'
and IsMatrix = 0 and IsDeleted = 0 
and ProjectTeam ='快百货' 
)

,t_orde as (  -- 每周出单明细
select 
	left(PayTime,7) pay_month 
	,WEEKOFYEAR( paytime) pay_week 
	,to_date(PayTime) pay_date 
	,OrderNumber ,PlatOrderNumber ,TotalGross,TotalProfit,TotalExpend ,SaleCount
	,ExchangeUSD,TransactionType,SellerSku,RefundAmount,AdvertisingCosts,PublicationDate,Asin,BoxSku ,PurchaseCosts
	,paytime
	,t.name 
from import_data.wt_orderdetails wo 
join t_prod t on wo.Product_Sku = t.sku 
join import_data.mysql_store ms on wo.shopcode=ms.Code 
	and paytime >= '2023-06-01' and paytime <'2023-07-01'
-- 	and paytime >= '2023-05-01' and paytime <'2023-06-01'
	and ms.Department = '快百货'
	and wo.IsDeleted=0
) 

select name ,round(sum(TotalGross/ExchangeUSD),2) 6月扣税扣退款销售额
from t_orde 
group by name 