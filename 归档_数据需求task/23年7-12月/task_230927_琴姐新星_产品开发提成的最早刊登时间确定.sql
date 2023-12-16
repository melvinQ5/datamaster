-- 第二版 刊登时间
with
pp as (
select
	epp.BoxSKU
 	, epp.SKU
 	, epp.SPU
 	, tt.pub_time
 	, epp.DevelopUserName
	, epp.ProductName
 	, DATE_FORMAT(pub_time,'%Y%m') as pub_month
 	, date(pub_time) as pub_date
 	, WEEKOFYEAR(pub_time) as pub_week
from import_data.erp_product_products epp
join (select SKU,min(PublicationDate) 'pub_time' from wt_listing wl
      join mysql_store s
      on wl.ShopCode=s.Code
      and s.Department='快百货'
      where PublicationDate>='2023-01-01'
      group by SKU) tt
on epp.SKU=tt.SKU
where epp.DevelopLastAuditTime >= '2023-01-01'
and epp.IsDeleted = 0 and epp.IsMatrix = 0
and epp.ProjectTeam ='快百货'
and developusername  not in('彭瑶','杨敏霞','郑燕飞','林家贤','杨桐桐')
)

-- 这里统计结算当月的
,od as(
select sku sku2,pp.DevelopUserName DevelopUserName1,count(distinct PlatOrderNumber) orders,round(sum(totalgross/ExchangeUSD),2) sales,round(sum(totalprofit/ExchangeUSD),2) profit,round(sum(feegross/ExchangeUSD),2) freightfee,round(sum(RefundAmount/ExchangeUSD),2) refund
from wt_orderdetails wo
join mysql_store s on s.code=wo.shopcode and s.department='快百货'
join  pp on pp.boxsku=wo.boxsku
where wo.IsDeleted = 0
and SettlementTime >= '2023-08-01' and SettlementTime<'2023-09-01'
group by sku,pp.DevelopUserName
)

-- 这里统计对应时间段的广告花费
,addetail as (
select al.sku sku1,pp.DevelopUserName DevelopUserName2,sum(adexposure)exposure,sum(adclicks)clicks,round(sum(adspend),2) spend
,sum(TotalskuSalecount7Day) adorders,sum(AdSales) adsales
from wt_adserving_amazon_daily ads
left join wt_listing al  on al.sellersku=ads.sellersku  and al.shopcode=ads.shopcode and al.asin=ads.asin
join pp on pp.sku=al.sku
join mysql_store s on s.code=ads.shopcode and s.department='快百货'
where GenerateDate>= '2023-08-01'
and GenerateDate<'2023-09-01'
group by  al.sku,pp.DevelopUserName
)


,datedata as (
select *,(case when pp.pub_time >= date_add('2023-09-01'   , interval -6 month) and  pp.pub_time< date_add('2023-09-01', interval -3 month)  then '3-6月' when pp.pub_time>=date_add('2023-09-01'   , interval -3 month) and pp.pub_time<'2023-09-01'    then '近3月' end ) developdate,round(clicks/exposure,4) ctr,round(adorders/clicks,4) cvr,round(spend/clicks,4) cpc, round(SPEND/adsales,4) acost, round(adsales/spend,2) ROI
from pp
left join od a on pp.sku=a.sku2
left join addetail b on pp.sku=b.sku1
)

,monthcal as
(
select DevelopUserName `开发人员`
,sum(case when developdate='近3月' then  orders end) `近3月开发商品订单数`
,sum(case when developdate='3-6月' then orders end)  `近3-6月开发商品订单数`
,round(sum(case when developdate='近3月' then  sales end),2) `近3月开发商品销售额`
,round(sum(case when developdate='3-6月' then sales end),2)  `近3-6月开发商品销售额`
,round(sum(case when developdate='近3月' then  refund end),2) `近3月开发商品退款`
,round(sum(case when developdate='3-6月' then refund end),2)  `近3-6月开发商品退款`
,round(sum(case when developdate='近3月' then  spend end),2) `近3月开发商品广告花费`
,round(sum(case when developdate='3-6月' then spend end),2)  `近3-6月开发商品广告花费`
,round(sum(case when developdate='近3月' then  (profit-spend) end),2)`近3月开发商品扣广告的利润额`
,round(sum(case when developdate='3-6月' then (profit-spend) end),2)`近3-6月开发商品扣广告的利润额`
,sum(case when developdate in('近3月', '3-6月')then  orders end) `近6个月开发商品当月总订单数`
,round(sum(case when developdate in('近3月', '3-6月')then  sales end),2) `近6个月开发商品当月总销售额`
,round(sum(case when developdate in('近3月', '3-6月')then (profit-spend) end),2) `近6个月开发商品当月总利润额`
FROM datedata
group by DevelopUserName
)

select *,round(`近6个月开发商品当月总利润额`/`近6个月开发商品当月总销售额`,4)`近6个月开发商品当月总利润率` from monthcal
order By `近6个月开发商品当月总销售额` desc ;



-- 刊登早于终审的清单
with pp as (
select
	epp.BoxSKU
 	, epp.SKU
 	, epp.SPU
 	, epp.DevelopLastAuditTime
    ,epp.CreationTime
 	, epp.DevelopUserName
	, epp.ProductName
 	, DATE_FORMAT(DevelopLastAuditTime,'%Y%m') as dev_month
 	, to_date(DevelopLastAuditTime) as dev_date
 	, WEEKOFYEAR(DevelopLastAuditTime) as dev_week
    ,pub_time
from import_data.erp_product_products epp
join (select SKU,min(PublicationDate) 'pub_time' from wt_listing wl
      join mysql_store s
      on wl.ShopCode=s.Code
      and s.Department='快百货'
      where PublicationDate>='2023-01-01'
      group by SKU) tt
on epp.SKU=tt.SKU
where epp.DevelopLastAuditTime >= '2023-01-01'
and epp.IsDeleted = 0 and epp.IsMatrix = 0
and epp.ProjectTeam ='快百货'
and developusername not in('彭瑶','杨敏霞','郑燕飞','林家贤','杨桐桐')
)


-- 这里统计结算当月的
,od as(
select sku sku2,pp.DevelopUserName DevelopUserName1,count(distinct PlatOrderNumber) orders,round(sum(totalgross/ExchangeUSD),2) sales,round(sum(totalprofit/ExchangeUSD),2) profit,round(sum(feegross/ExchangeUSD),2) freightfee,round(sum(RefundAmount/ExchangeUSD),2) refund
from wt_orderdetails wo
join mysql_store s on s.code=wo.shopcode and s.department='快百货'
join  pp on pp.boxsku=wo.boxsku
where wo.IsDeleted = 0 and SettlementTime >= date_add('2023-09-01',interval -1 month ) and SettlementTime <'2023-09-01'
group by sku,pp.DevelopUserName
)
-- 这里统计对应时间段的广告花费
,addetail as (
select al.sku sku1,pp.DevelopUserName DevelopUserName2,sum(adexposure)exposure,sum(adclicks)clicks,round(sum(adspend),2) spend
,sum(TotalskuSalecount7Day) adorders,sum(AdSales) adsales
from wt_adserving_amazon_daily ads
left join wt_listing al  on al.sellersku=ads.sellersku  and al.shopcode=ads.shopcode and al.asin=ads.asin
join pp on pp.sku=al.sku
join mysql_store s on s.code=ads.shopcode and s.department='快百货'
where GenerateDate>= date_add('2023-09-01',interval -1 month )  and GenerateDate <'2023-09-01'
group by  al.sku,pp.DevelopUserName
)

select BoxSKU,SKU,DevelopLastAuditTime '终审时间',pub_time 刊登时间
    ,CreationTime 产品添加时间
    ,timestampdiff(day,DevelopLastAuditTime,pub_time) 刊登减终审天数
from pp
join od a on pp.sku=a.sku2
where pub_time<DevelopLastAuditTime ;



--


--  sku = 1101153.01 ERP显示在线链接是特卖汇
select SKU ,min(PublicationDate) 'pub_time' from wt_listing wl
    join mysql_store s
    on wl.ShopCode=s.Code
    and s.Department='快百货'
where PublicationDate >= '2023-01-01' and sku =  1101153.01
group by SKU

select PublicationDate,ListingStatus ,*
from wt_listing wl
join mysql_store s
on wl.ShopCode=s.Code
and s.Department='快百货'
where sku =  1101153.01 and ListingStatus =1


select *
from erp_amazon_amazon_listing eaal
join mysql_store s
on eaal.ShopCode=s.Code
and s.Department='快百货'
where sku =  5256496.01  and ListingStatus =1
