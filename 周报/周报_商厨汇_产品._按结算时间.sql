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

,orderdetails as (
select wo.id,OrderNumber ,PlatOrderNumber ,TotalGross,TotalProfit,TotalExpend,ExchangeUSD
	,TransactionType,SellerSku,RefundAmount,AdvertisingCosts
	, case when ShipWarehouse regexp 'FBA' then 'FBA模式' else 'FBM模式' end mode
	,ShipWarehouse
	,wo.boxsku
	,pp.Spu
	,ms.* 
	,tb.person 
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
	,ad.*
from import_data.mysql_store ms 
join import_data.AdServing_Amazon ad
	on ad.CreatedTime >=date_add('${StartDay}',interval -1 day) and ad.CreatedTime<date_add('${NextStartDay}',interval -1 day)
		and ad.ShopCode = ms.Code  and ms.department = '商厨汇'	
left join (select boxsku ,ShopCode ,Asin ,SellerSku 
	from wt_listing wl
	inner join import_data.mysql_store ms
		on wl.ShopCode=ms.Code  and ms.department = '商厨汇' 
	group by boxsku ,ShopCode ,Asin ,SellerSku
	) wl 
	on ad.ShopCode =wl.ShopCode and ad.Asin =wl.ASIN and ad.SellerSku = ad.SellerSku 	
)

/*访客数据*/
, visitor as (
select wl.boxsku ,s.*,round((TotalCount*FeaturedOfferPercent)/100,2) '访客数',OrderedCount '访客销量' 
from import_data.ListingManage lm
inner join import_data.mysql_store s
	on lm.ShopCode=s.Code and s.department = '商厨汇'
	and ReportType='周报' 
-- 	and ReportType='月报' 	
	and Monday='${StartDay}' 
left join (select boxsku ,ShopCode ,Asin 
	from wt_listing wl
	inner join import_data.mysql_store s on wl.ShopCode=s.Code and s.department = '商厨汇'
	group by boxsku ,ShopCode ,Asin 
	) wl 
	on lm.ShopCode =wl.ShopCode and lm.ChildAsin =wl.ASIN 
)

/*退款数据*/
,RefundAmount as ( 
select dod.BoxSku
	,dod.ShipWarehouse
	,s.Department,s.NodePathName,s.Code 
	,rf.RefundDate
	,ifnull(rf.RefundUSDPrice,0) RefundUSDPrice
	,rf.RefundReason1
	,rf.RefundReason2 
	,rf.ShipDate 
	,rf.OrderNumber 
from import_data.daily_RefundOrders rf
join import_data.mysql_store s 
	on rf.OrderSource=s.Code and RefundStatus ='已退款'
		and RefundDate>='${StartDay}'
		and RefundDate<'${NextStartDay}'
		and s.department = '商厨汇'
left join (select OrderNumber ,ShipWarehouse ,GROUP_CONCAT(boxsku) as BoxSku
	from import_data.wt_orderdetails where IsDeleted = 0 and TransactionType ='付款'
	group by OrderNumber ,ShipWarehouse 
	) dod -- 经验证一个ordernumber 只对应了 一个boxsku 
	on dod.OrderNumber  =rf.OrderNumber 
)


/*【Part2 单一指标】*/
, sl as ( 
select BoxSku 
	,round(sum(TotalGross/ExchangeUSD),2) `销售额`
	,round(sum(TotalProfit/ExchangeUSD),2) `利润额`
	,round(sum(TotalProfit/ExchangeUSD)/sum(TotalGross/ExchangeUSD),2) `毛利率`
	,round(sum( case when mode='FBA模式' then TotalGross/ExchangeUSD end ),2) `FBA销售额`
	,round(sum( case when mode='FBM模式' then TotalGross/ExchangeUSD end ),2) `FBM销售额`
	, count(distinct OrderNumber)/ datediff('${NextStartDay}','${StartDay}') `日均订单数`
from orderdetails 
group by BoxSku
)
    
, Ads as (
select BoxSku
	,sum(spend) '广告表广告花费' 
	,sum(TotalSale7Day) '广告销售额' 
	,round(sum(spend)/sum(TotalSale7Day),4) 'Acost'
	,sum(Exposure) 'exp' 
	,sum(Clicks) 'clk' ,round(sum(Clicks)/sum(Exposure),4) '广告点击率',round(sum(TotalSale7DayUnit)/sum(Clicks),4) '广告转化率'
from adserving
group by BoxSku
)

, ls as (
select BoxSku,sum(访客数) as 访客数,sum(访客销量)as '访客销量' from visitor
group by BoxSku
)

, rd as (
select BoxSku 
	,ifnull(sum( RefundUSDPrice ),0) '退款表退款' 
	,sum(case when !(RefundReason1='客户原因' and ShipDate = '2000-01-01') then RefundUSDPrice else 0 end) '非客户原因退款金额' 
from RefundAmount 
group by BoxSku
)

-- 
, t_merage as (
select 
	sl.BoxSku 
	,tb.person 
	,sl.`销售额`
	,sl.`FBA销售额`
	,sl.`FBM销售额`
	,sl.`利润额`
	,sl.`毛利率`
	,sl.`日均订单数`
	,ifnull(广告表广告花费,0) as 广告表广告花费
	,ifnull(广告销售额,0) as 广告销售额
	,Acost,exp,clk
	,广告点击率
	,广告转化率
	,访客数
	,访客销量 
	,`退款表退款` 
from sl
left join rd
on sl.BoxSku=rd.BoxSku
left join Ads
on sl.BoxSku=Ads.BoxSku
left join ls
on sl.BoxSku=ls.BoxSku 
left join tb on  sl.BoxSku =tb.boxsku 
where sl.BoxSku <> 'shopfee' 
)


/*【Part3 复合指标】*/
select 
	replace(concat(right('${StartDay}',5),'至',right(to_date(date_add('${NextStartDay}',-1)),5)),'-','') `订单结算时间`
	,t_merage.BoxSku `出单boxsku`
	,t_merage.person `运营人员`
	,t2.ProductName `产品名称`
	,t2.ProductStatus `产品状态`
	,t2.CategoryPathByChineseName `产品类目`
	,round(FBA销售额,2) as 'FBA销售额'
	,round(FBM销售额,2) as 'FBM销售额'
	,round(销售额,2) as '销售额'
	,round(利润额,2) '利润额' 
	,round(毛利率,3) `毛利率`
	,广告表广告花费
	,round(`日均订单数`,1) 日均订单数 
	,退款表退款 as 退款金额
	,round(退款表退款/销售额,4) '退款率'
	,round(广告表广告花费,2) as '广告花费'
	,round(广告表广告花费/销售额,4) '广告花费占比'
	,round(Acost,4) as 'Acost'
	,round(广告销售额/销售额,4) '广告业绩占比'
	,round(广告点击率,4) as '广告点击率'
	,round(广告转化率,4) as '广告转化率'
	,exp '曝光量'
	,clk '点击量'
	,round(访客数)as '访客数'
--  ,访客销量
-- 	,round(访客销量/访客数,4) '访客转化率'
-- 	,round((访客数-clk)/访客数,4) '自然流量占比' 
from t_merage 
left join t2 on t2.boxsku = t_merage.boxsku
where t_merage.BoxSku <> 'ShopFee' 
order by t2.boxsku 
