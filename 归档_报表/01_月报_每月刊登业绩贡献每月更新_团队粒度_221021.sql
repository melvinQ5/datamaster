-- 团队粒度
-- 使用宽表计算 每月跑一版存储
with 
ords as (
select * 
from (
SELECT
	wo.Department, wo.shopcode
	,DATE_FORMAT(wl.PublicationDate,"%Y%m") as pub_month
	,DATE_FORMAT(wo.SettlementTime ,"%Y%m") as set_month
	,wo.OrderNumber ,wo.SellerSku ,wo.BoxSku
   	,sum(wo.TotalGross/ExchangeRMB) as TotalGross_g 
   	,sum(wo.TotalProfit/ExchangeRMB) as TotalProfit_g 
from import_data.wt_orderdetails wo
join import_data.wt_listing wl on wo.SellerSku =wl.SellerSKU and wo.shopcode = wl.ShopCode and wl.SellerSKU not regexp '-BJ-|-BJ|BJ-' 
where wo.SettlementTime >= '2022-04-01' and wl.PublicationDate >= '2022-04-01'
group by wo.Department, wo.shopcode
	,DATE_FORMAT(wl.PublicationDate,"%Y%m")
	,DATE_FORMAT(wo.SettlementTime ,"%Y%m")
	,wo.OrderNumber ,wo.SellerSku ,wo.BoxSku) tmp 
where pub_month <= set_month
)



, order_res as ( -- 出单数据
select Department ,pub_month ,set_month 
	,sum(TotalGross_g) as sales
    ,sum(TotalProfit_g) as profit
    ,count(distinct OrderNumber) as ord_cnt -- 订单数
   	,count(distinct BoxSku) as ord_sku_cnt -- 出单sku数
   	,count(distinct concat(SellerSku,shopcode)) as ord_listing_cnt -- 出单链接数
from ords 
group by Department,pub_month ,set_month 
)

, list_res as ( -- 上架数据
select ws.Department 
	, DATE_FORMAT(wl.PublicationDate,"%Y%m") pub_month
	, count(distinct Id) as pub_listing_cnt
	, count(distinct Sku) as pub_sku_cnt
from import_data.wt_listing wl 
join import_data.wt_store ws on wl.ShopCode = ws.Code
where wl.PublicationDate >= '2022-04-01'
group by ws.Department ,StoreOperateMode
	, DATE_FORMAT(wl.PublicationDate,"%Y%m") 
)
	

SELECT
    CASE
        WHEN or1.Department = '销售一部' THEN 'GM-销售1部'
        WHEN or1.Department = '销售二部' THEN 'PM-销售2部'
        WHEN or1.Department = '销售三部' THEN 'PM-销售3部'
    END AS `销售部门`
    ,CASE
        WHEN or1.Department = '销售一部' THEN 'GM'
        WHEN or1.Department IN ('销售二部', '销售三部') THEN 'PM'
    END AS `模式`
    ,or1.pub_month `上架月份`
    ,or1.set_month `出单月份`
    ,or1.sales `当月销售额`
    ,or1.profit `当月利润额`
    ,round(or1.profit/or1.sales,4) `利润率` -- 利润率
	,or1.ord_cnt `当月订单数` -- 订单数
	,round(or1.sales/or1.ord_cnt,1) `客单价` -- 客单价
   	,or1.ord_sku_cnt `出单sku数`
   	,lr.pub_sku_cnt `刊登sku数`
   	,round(or1.ord_sku_cnt/lr.pub_sku_cnt,4) `SKU出单率`
   	,or1.ord_listing_cnt `出单链接数`
   	,lr.pub_listing_cnt `刊登链接数`
   	,round(or1.ord_listing_cnt/lr.pub_listing_cnt,4)  `链接出单率`
   	,round(lr.pub_listing_cnt/lr.pub_sku_cnt,4)  `平均SKU链接数`
FROM
    order_res or1
LEFT join list_res lr ON or1.Department = lr.Department AND or1.pub_month = lr.pub_month

