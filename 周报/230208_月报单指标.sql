-- 商厨汇：HAMGD-VD HAMGD-VK  HAMBS-QV

with 

-- 公司 销售模块
select round(sum(TotalGross/ExchangeUSD),2) as `销售额usd` 
	,round(sum(TotalProfit/ExchangeUSD),2) as `利润额usd`  
	,count(distinct OrderNumber) `订单数`
	,sum(SaleCount) `订单产品件数` 
from wt_orderdetails wo
join import_data.wt_store ws on wo.shopcode = ws.Code 
and SettlementTime >= '${StartDay}' and SettlementTime  < '${EndDay}'  
and IsDeleted = 0 and ws.Department in ('特卖汇','快百货','MRO孵化部','商厨汇')


-- 部门 销售模块
select ws.Department, round(sum(TotalGross/ExchangeUSD),2) as `销售额usd` 
	,round(sum(TotalProfit/ExchangeUSD),2) as `利润额usd` 
	,round(sum(TotalGross/ExchangeUSD)/sum(TotalProfit/ExchangeUSD),2) `利润率`
	,count(distinct OrderNumber) `订单数`
	,sum(SaleCount) `订单产品件数` 
from wt_orderdetails wo
join import_data.wt_store ws on wo.shopcode = ws.Code 
and SettlementTime  < '${NextFirstDay}' and SettlementTime >= date_add('${NextFirstDay}',interval -1 month)
and IsDeleted = 0 and ws.Department in ('特卖汇','快百货','MRO孵化部')
group by ws.Department 

-- 商厨汇 销售额 三个账号+1个账号
select 
from 



-- 部门+产品销售额 
select * from JinqinSku js where monday = '2023-02-11'

-- 快百货 新品开发SPU数
, t_kbh_new_spu as (
	select  count(distinct Spu) `新品开发SPU数`
	from 
	( 
	select Spu, epp.BoxSKU ,ProjectTeam ,DevelopLastAuditTime
	from import_data.erp_product_products epp 
	where DevelopLastAuditTime  < '${EndDay}' and DevelopLastAuditTime >= '${StartDay}'
		and IsMatrix = 1 and ProjectTeam='快百货'
	) pt
)

-- 特卖汇 逆向开发SPU数
, t_tmh_reverse_spu as (
	select  count(distinct SKU) `新品开发SKU数`
	from 
	( 
	select Spu, epp.SKU, epp.BoxSKU ,ProjectTeam ,DevelopLastAuditTime
	from import_data.erp_product_products epp 
	where DevelopLastAuditTime  < '${EndDay}' and DevelopLastAuditTime >= '${StartDay}'
		and ProjectTeam='特卖汇' 
		and skusource=2
	) pt
)



-- 新品N天动销率 14 看1-15日数据  30
select round(tmp.ord14_sku_cnt/prod_spu.new_spu_cnt,3) d14_rate 
	,round(tmp.ord30_sku_cnt/prod_spu.new_spu_cnt,3) d30_rate
from (
	select count(distinct case when datediff(DATE_ADD(CURRENT_DATE(), interval -14 day),DevelopLastAuditTime)>0 and 0 < (FirstOrderTimeCost*-1)/86400 and (FirstOrderTimeCost*-1)/86400 <= 14 then spu end) ord14_sku_cnt
	, count(distinct case when datediff(DATE_ADD(CURRENT_DATE(), interval -30 day),DevelopLastAuditTime)>0 and 0 < (FirstOrderTimeCost*-1)/86400 and (FirstOrderTimeCost*-1)/86400 <= 30 then spu end) ord30_sku_cnt
	from import_data.wt_products where DevelopLastAuditTime  < '${NextFirstDay}' and DevelopLastAuditTime >= date_add('${NextFirstDay}',interval -1 month)
	) tmp
,( 
	select count(distinct Spu) new_spu_cnt
	from import_data.erp_product_products epp 
	where DevelopLastAuditTime  < '${NextFirstDay}' and DevelopLastAuditTime >= date_add('${NextFirstDay}',interval -1 month)
		and IsMatrix = 1
	) prod_spu;
	
-- 新品30天单产

-- 新品广告点击率、转化率 新品定义  终审时间在2023年产品
select  
		round((sum(AdClicks)/ sum(AdExposure)), 4) '广告点击率',
		round((sum(AdSaleUnits)/ sum(AdClicks)), 4) '广告转化率'
from import_data.wt_adserving_amazon_daily aa
join ( select eaal.id
-- 	,eaal.SellerSKU ,eaal.ShopCode ,eaal.ASIN 
	from erp_amazon_amazon_listing  eaal
	join erp_product_products epp on eaal.SKU =epp.SKU and DevelopLastAuditTime >= '2023-01-01'
	) al
	on aa.ListingId  = al.id 
where GenerateDate >= '2023-01-01' and GenerateDate <= '2023-01-31'



