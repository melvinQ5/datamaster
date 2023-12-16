/*
新品开发N天出单率=对应PM出单SKU数/开发完成SKU数
对开发终审时间按周来分组sk，计算每个sku的首单天数。

每个sku只有一个 首单天数（最早出单日期-开发完成日期）,每笔订单的每个sku只有1个 首单天数,
按首单天数，则"30天首单动销率"的业务含义是：7月开发完成的sku中，有多少个能在30天内就能至少开出1单

对于GM转PM（有开发终审时间且skuSource=2的SKU），即SKU先跟卖出效果的，我们进行SKU开发终审，然后让二部三部去卖。
所以计算其最早出单时间的时候也是开发终审之后，因此其首单天数也为正数。
*/

with
tmp_epp as (
select
	epp.BoxSKU
 	, epp.SKU
 	, epp.SPU
 	, DevelopLastAuditTime
    , tmp_min.min_pubtime
 	, epp.DevelopUserName
 	, case when epp.SkuSource=1 then '正向' when epp.SkuSource=2 then 'GM转PM'
		when epp.SkuSource=3 then '采集' when epp.SkuSource is null then '来源为空' end  SkuSource_cn -- `sku来源`
 	, DATE_FORMAT(DevelopLastAuditTime,'%Y%m') as dev_month
 	, dd.week_begin_date
 	, dd.week_num_in_year as dev_week
from import_data.erp_product_products epp
left join dim_date dd on date(date_add(epp.DevelopLastAuditTime, INTERVAL - 8 hour)) = dd.full_date
left join ( select SPU, min(MinPublicationDate) as min_pubtime from import_data.wt_listing
    where IsDeleted = 0 group by SPU
    ) tmp_min on tmp_min.SPU =epp.SPU
where DevelopLastAuditTime >= '2023-07-01' and epp.IsDeleted = 0 and epp.IsMatrix = 0
	and epp.ProjectTeam ='快百货'
)


, orders as (
select * from (
	select tmp.*
 		, timestampdiff(SECOND,min_pubtime,PayTime)/86400 as ord_days_since_lst -- 处理终审时间大于最早刊登时间的脏数据,以最终刊登时间为终审，避免刊登动销率小于了终审动销率
	from (
		select od.PlatOrderNumber
			,  epp.DevelopLastAuditTime 
			, od.PayTime , ms.Department ,ms.NodePathName
			, epp.SkuSource_cn, epp.SPU, epp.SKU, epp.BoxSku, epp.DevelopUserName, od.shopcode as ShopIrobotId, od.SellerSku
			, wl.min_pubtime
			, TotalGross/ExchangeUSD as AfterTax_TotalGross
			, TotalProfit/ExchangeUSD as AfterTax_TotalProfit
		from import_data.wt_orderdetails od
		join import_data.mysql_store ms on ms.Code = od.shopcode and od.IsDeleted = 0
			and ms.Department ='快百货' and PayTime >= '2023-01-01'
		join tmp_epp epp on od.BoxSku =epp.BoxSKU
		left join (select BoxSku, min( MinPublicationDate ) min_pubtime from wt_listing wl
            join import_data.mysql_store ms on ms.Code = wl.shopcode and wl.IsDeleted = 0
			and ms.Department ='快百货' group by BoxSku )  wl on  wl.BoxSku = od.boxsku
		) tmp
	) tmp2

)

, t0 as (
select spu ,ord30_orders_since_lst
from
    ( select od.SPU
        , count(distinct case when 0 <= ord_days_since_lst and ord_days_since_lst  <= 30 then PlatOrderNumber end) as ord30_orders_since_lst
    from tmp_epp t left join orders od on od.BoxSku =t.BoxSKU  group by od.SPU
    ) ta
where ord30_orders_since_lst >= 6
)

select t0.spu ,t0.ord30_orders_since_lst 刊登30天出单数
    ,ProductName 产品名称
    ,date(DevelopLastAuditTime) 终审时间
    ,DevelopUserName 开发人员
from t0
left join erp_product_products epp on t0.spu =epp.spu and epp.IsDeleted=0 and epp.IsMatrix=1
order by ord30_orders_since_lst asc 