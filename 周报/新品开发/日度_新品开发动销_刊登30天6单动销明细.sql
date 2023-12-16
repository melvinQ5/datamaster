with
 orders as (
select * from (
	select tmp.*
 		, timestampdiff(SECOND,min_pubtime,PayTime)/86400 as ord_days_since_lst -- 处理终审时间大于最早刊登时间的脏数据,以最终刊登时间为终审，避免刊登动销率小于了终审动销率
	from (
		select od.PlatOrderNumber
			, od.PayTime , ms.Department ,ms.NodePathName
			,  epp.SPU, epp.SKU, epp.BoxSku, od.shopcode as ShopIrobotId, od.SellerSku
			, wl.min_pubtime
			, TotalGross/ExchangeUSD as AfterTax_TotalGross
			, TotalProfit/ExchangeUSD as AfterTax_TotalProfit
		    ,SaleCount
		from import_data.wt_orderdetails od
		join import_data.mysql_store ms on ms.Code = od.shopcode and od.IsDeleted = 0
			and ms.Department ='快百货' and PayTime >= '2023-01-01'
		join view_kbp_new_products epp on od.BoxSku =epp.BoxSKU
		left join ( select BoxSku, min( MinPublicationDate ) min_pubtime from wt_listing wl join mysql_store ms on wl.ShopCode = ms.Code group by BoxSku )  wl on  wl.BoxSku = od.boxsku
		) tmp
	) tmp2
)


,od_stat as (
select sku
    ,count(distinct case when 0 <= ord_days_since_lst and ord_days_since_lst  <= 30 then PlatOrderNumber end) 刊登30天订单数
    ,count(distinct  PlatOrderNumber ) 累计订单数
    ,sum(salecount ) 累计销量
    ,round( sum(AfterTax_TotalGross) ) 累计销售额
from orders od
group by sku  having count(distinct case when 0 <= ord_days_since_lst and ord_days_since_lst  <= 30 then PlatOrderNumber end)  >=6
)

select
    spu
    ,os.sku
    ,BoxSku
    ,ProductName 产品名称
    ,DevelopLastAuditUserName 开发人员
    ,date(DevelopLastAuditTime) 终审日期
    ,case when wp.ProductStatus = 0 then '正常'
		when wp.ProductStatus = 2 then '停产'
		when wp.ProductStatus = 3 then '停售'
		when wp.ProductStatus = 4 then '暂时缺货'
		when wp.ProductStatus = 5 then '清仓'
		end as 产品状态
    ,刊登30天订单数
    ,累计订单数 ,累计销量 ,累计销售额
from od_stat os
left join wt_products wp on wp.sku = os.sku and wp.ProjectTeam = '快百货'
order by 终审日期 desc