-- 区分发货模式维度 FBA、FBM
with 
ta as (
select 
['4527356-李玉兰',
'4527345-李玉兰',
'4527299-黄堰霞',
'4522608-李玉兰',
'4483385-李玉兰',
'4483309-黄堰霞',
'4478402-黄堰霞',
'4478401-李玉兰',
'4475962-黄堰霞',
'4459364-李玉兰',
'4456462-黄堰霞',
'4375397-黄堰霞',
'4375396-黄堰霞',
'4346706-李玉兰',
'4346694-李玉兰',
'4346685-李玉兰',
'4346663-黄堰霞',
'4332620-黄堰霞',
'4332500-黄堰霞',
'3547351-李玉兰',
'3547350-李玉兰',
'3547343-黄堰霞'] arr 
)

,tb as (
select split(arr,"-")[1] as boxsku ,split(arr,"-")[2] as person
from (select unnest as arr 
	from ta ,unnest(arr)
	) tmp 
)

,t2 as ( 
select wp.CategoryPathByChineseName , wp.BoxSku 
	,case when wp.ProductStatus = 0 then '正常'
		when wp.ProductStatus = 2 then '停产'
		when wp.ProductStatus = 3 then '停售'
		when wp.ProductStatus = 4 then '暂时缺货'
		when wp.ProductStatus = 5 then '清仓'
		end as ProductStatus
	,wp.ProductName  
from import_data.wt_products wp 
where IsDeleted =0 
)

, orderdetails as (
select OrderNumber 
	,PlatOrderNumber
	,ExchangeUSD 
	,TotalGross,TotalProfit,TotalExpend
	,TransactionType,SellerSku,RefundAmount,AdvertisingCosts
	, case when ShipWarehouse regexp 'FBA' then 'FBA模式' else 'FBM模式' end mode
	,ShipWarehouse
	,wo.boxsku
	,pp.Spu
	,ms.* 
	,tb.person
	,SettlementTime
	,PayTime 
	,pp.ProductName 
from import_data.wt_orderdetails wo 
inner join import_data.mysql_store ms on wo.shopcode=ms.Code 
	and wo.IsDeleted=0 
	and ms.department = '商厨汇'
left join wt_products pp on wo.BoxSku=pp.BoxSku
join tb on tb.boxsku = wo.BoxSku 
where SettlementTime  >='${StartDay}' and SettlementTime  < '${NextStartDay}'
)


/*广告数据*/
, adserving as (
select 
	wl.BoxSku 
	,person 
	,ad.*
from import_data.mysql_store ms 
join import_data.AdServing_Amazon ad
	on ad.CreatedTime >=date_add('${StartDay}',interval -1 day) and ad.CreatedTime<date_add('${NextStartDay}',interval -1 day)
		and ad.ShopCode = ms.Code  and ms.department = '商厨汇'	
left join (select wl.boxsku ,ShopCode ,Asin ,SellerSku ,person 
	from wt_listing wl
	left join tb on wl.boxsku = tb.boxsku 
	inner join import_data.mysql_store ms
		on wl.ShopCode=ms.Code  and ms.department = '商厨汇' 
	group by wl.boxsku ,ShopCode ,Asin ,SellerSku,person 
	) wl 
	on ad.ShopCode =wl.ShopCode and ad.Asin =wl.ASIN and ad.SellerSku = ad.SellerSku 	
)

/*访客数据*/
, visitor as (
select wl.boxsku ,person 
	,s.* 
	,round((TotalCount*FeaturedOfferPercent)/100,2) '访客数' 
	,OrderedCount '访客销量' 
from import_data.ListingManage lm
inner join import_data.mysql_store s
	on lm.ShopCode=s.Code and s.department = '商厨汇'
	and ReportType='周报' 	
	and Monday='${StartDay}' 
left join (select wl.boxsku ,ShopCode ,Asin ,person 
	from wt_listing wl
	inner join import_data.mysql_store s on wl.ShopCode=s.Code and s.department = '商厨汇'
	left join tb on wl.boxsku = tb.boxsku 
	group by wl.boxsku ,ShopCode ,Asin ,person 
	) wl 
	on lm.ShopCode =wl.ShopCode and lm.ChildAsin =wl.ASIN 
)

/*【Part2 单一指标】*/
, sl as ( 
select person 
	,round(sum(TotalGross/ExchangeUSD),2) `销售额`
	,round(sum(TotalProfit/ExchangeUSD),2) `利润额`
	,round(sum(TotalProfit/ExchangeUSD)/sum(TotalGross/ExchangeUSD),2) `利润率`
	, count(distinct OrderNumber)/ datediff('${NextStartDay}','${StartDay}') `日均订单数`
from orderdetails 
group by person
)

, Ads as (
select person
	,sum(spend) '广告表广告花费' 
	,sum(TotalSale7Day) '广告销售额' 
	,round(sum(spend)/sum(TotalSale7Day),4) 'Acost'
	,sum(Exposure) 'exp' 
	,sum(Clicks) 'clk' ,round(sum(Clicks)/sum(Exposure),4) '广告点击率',round(sum(TotalSale7DayUnit)/sum(Clicks),4) '广告转化率'
from adserving
group by person
)

, ls as (
select person,sum(访客数) as 访客数,sum(访客销量)as '访客销量' 
from visitor
group by person
)

-- 导订单明细
-- select 
-- 	 OrderNumber `塞盒订单号`
-- 	,PlatOrderNumber `平台订单号`
-- 	,SettlementTime `结算时间`
-- 	,code `店铺` 
-- 	,person `运营人员`
-- 	,boxsku
-- 	,productname `产品名称`
-- 	,round(TotalGross/ExchangeUSD) `总收入usd`
-- 	,round(TotalProfit/ExchangeUSD) `总利润usd`
-- 	,round(TotalExpend/ExchangeUSD) `总成本usd`
-- 	,TransactionType `交易类型`
-- 	,AdvertisingCosts `其他类型对应扣除店铺费用`
-- 	,SellerSku `渠道SKU`
-- 	,case when ShipWarehouse regexp 'FBA' then 'FBA模式' else 'FBM模式' end mode
-- 	,ShipWarehouse `发货仓库`
-- from orderdetails
-- order by TransactionType

-- 导广告明细
-- select 
-- 	shopcode `店铺`
-- 	,StoreSite `站点`
-- 	,AdActivityName `广告活动`
-- 	,AdGroupName `广告组`
-- 	,SellerSKU ,Asin
-- 	,BoxSku `通过链接匹配boxsku` 
-- 	,person `运营人员`
-- 	,sum(spend) '广告花费' 
-- 	,sum(TotalSale7Day) '广告销售额' 
-- 	,round(sum(spend)/sum(TotalSale7Day),4) 'Acost'
-- 	,sum(Exposure) '曝光量' 
-- 	,sum(Clicks) '点击量' 
-- 	,sum(TotalSale7DayUnit) `广告销量`
-- 	,round(sum(Clicks)/sum(Exposure),4) '广告点击率'
-- 	,round(sum(TotalSale7DayUnit)/sum(Clicks),4) '广告转化率'
-- from adserving
-- group by shopcode,StoreSite ,AdActivityName ,AdGroupName ,SellerSKU ,Asin ,BoxSku ,person 

select 
	replace(concat(right('${StartDay}',5),'至',right(to_date(date_add('${NextStartDay}',-1)),5)),'-','') `订单结算时间`
	,sl.person 
	,sl.`销售额`
	,sl.`利润额`
	,sl.`利润率`
	,round(sl.`日均订单数`,1) 日均订单数
	,ifnull(广告表广告花费,0) as 广告表广告花费
	,ifnull(广告销售额,0) as 广告销售额
	,Acost 
	,exp 曝光量
	,clk 点击量
	,广告点击率
	,广告转化率
	,访客数
	,访客销量 
	,round(广告点击率,4) as '广告点击率'
	,round(广告转化率,4) as '广告转化率'
	,exp '曝光量'
	,clk '点击量'
-- 	,round(访客数)as '访客数'
--        ,访客销量
-- 	,round(访客销量/访客数,4) '访客转化率'
-- 	,round((访客数-clk)/访客数,4) '自然流量占比' 
from sl
left join Ads
on sl.person=Ads.person 
left join ls
on sl.person=ls.person 