
with 
-- step1 数据源处理 
t_key as ( -- 结果集的主维度
select '公司' as dep
union select '快百货' 
union select '商厨汇' 
union 
select case when NodePathName regexp '泉州' then '快百货二部' when NodePathName regexp '成都' then '快百货一部'  else department end as dep from import_data.mysql_store where department regexp '快' 
union 
select NodePathName from import_data.mysql_store where department regexp '快' 
)

,t_mysql_store as (  
select 
	Code 
	,case 
		when NodePathName regexp '成都' then '快百货一部'  else '快百货二部' 
		end as department
	,NodePathName
	,department as department_old
	,ShopStatus
from import_data.mysql_store where Department regexp '快'
)

,t_elem as ( -- 元素维度
select eppaea.spu ,eppaea.sku ,t_prod.boxsku ,eppea.Name ,t_prod.DevelopLastAuditTime
	,t_prod.ProjectTeam
from import_data.erp_product_product_associated_element_attributes eppaea 
left join import_data.erp_product_product_element_attributes eppea on eppaea.ElementAttributeId = eppea.Id
join import_data.erp_product_products t_prod on eppaea.sku = t_prod.sku and t_prod.ismatrix = 0 and t_prod.IsDeleted =0 
group by eppaea.spu ,eppaea.sku ,t_prod.boxsku ,eppea.Name ,t_prod.DevelopLastAuditTime,t_prod.ProjectTeam
)

,t_orde as (
select wo.id ,OrderNumber ,PlatOrderNumber ,TotalGross,TotalProfit,TotalExpend ,FeeGross 
	,ExchangeUSD,TransactionType,SellerSku,RefundAmount,AdvertisingCosts ,RefundReason2
	,pp.SPU
	,ms.*
	,elem.ele_boxsku
from import_data.wt_orderdetails wo 
join t_mysql_store ms on wo.shopcode=ms.Code
left join wt_products pp on wo.BoxSku=pp.BoxSku
left join ( select spu ,BoxSku as ele_boxsku ,DevelopLastAuditTime from t_elem group by spu ,BoxSku ,DevelopLastAuditTime ) elem 
	on wo.BoxSku = elem.ele_boxsku -- 筛选元素品
where PayTime >='${StartDay}' and PayTime<'${NextStartDay}' and wo.IsDeleted=0  -- 周报
-- and OrderStatus !='作废'
-- where SettlementTime  >='${StartDay}' and SettlementTime<'${NextStartDay}' and wo.IsDeleted=0
)



-- ,t_refd as (
-- select rf.RefundUSDPrice,RefundReason1,RefundReason2 ,ShipDate 
-- 	,ms.*
-- from import_data.daily_RefundOrders rf 
-- join t_mysql_store ms
-- 	on rf.OrderSource=ms.Code and RefundStatus ='已退款'
-- 		and RefundDate>='${StartDay}' and RefundDate<'${NextStartDay}'
-- )

,t_refd as (
select abs(RefundAmount/ExchangeUSD) as RefundUSDPrice,RefundReason1,RefundReason2 , ShipTime as ShipDate 
	,ms.*
from wt_orderdetails wo
join ( select case when NodePathName regexp  '成都' then '快百货成都' else '快百货泉州' end as dep2,*
    from import_data.mysql_store where department regexp '快')  ms on ms.code=wo.shopcode and ms.department='快百货'
where wo.IsDeleted = 0 and TransactionType = '退款' and SettlementTime >='${StartDay}' and SettlementTime < '${NextStartDay}'
)

,t_adse as (
select 
	ad.ShopCode ,ad.SellerSKU ,ad.Asin ,ad.Spend as AdSpend 
	,ad.TotalSale7Day as AdSales 
	,ad.AdOtherSale7Day as AdSales_othersku
		,ms.*
from t_mysql_store ms
join import_data.AdServing_Amazon ad
	on ad.CreatedTime >=date_add('${StartDay}',interval -1 day) and ad.CreatedTime<date_add('${NextStartDay}',interval -1 day)
-- 	on ad.CreatedTime >='${StartDay}' and ad.CreatedTime< '${NextStartDay}'
		and ad.ShopCode = ms.Code  
)

,t_new_list as ( -- 新刊登链接维度
select ListingStatus ,SKU ,MinPublicationDate ,eaal.ShopCode ,SellerSKU ,ASIN ,SPU
	,ms.department ,ms.NodePathName
from import_data.wt_listing  eaal
join t_mysql_store ms on eaal.ShopCode = ms.Code 
where MinPublicationDate >= '${StartDay}' and MinPublicationDate <'${NextStartDay}' 
	and SellerSku not regexp 'bJ|Bj|bj|BJ' and ListingStatus != 4  and IsDeleted = 0 
)



-- step2 派生指标 = 统计期+叠加维度+原子指标
,t_sale_stat as ( 
select case when department IS NULL THEN '公司' ELSE department END AS dep 
	,round( sum((TotalGross-RefundAmount)/ExchangeUSD),2) `税后销售额`
	,round( sum(TotalExpend/ExchangeUSD)) `订单表总支出`
	,round( sum(ifnull((case when TransactionType='其他' and left(SellerSku,10)='ProductAds' 
		then AdvertisingCosts/ExchangeUSD end),0))) `其他类型统一扣除`
	,round( sum((TotalExpend/ExchangeUSD)-ifnull((case when TransactionType='其他' and left(SellerSku,10)='ProductAds' 
		then AdvertisingCosts/ExchangeUSD end),0)),2) `订单表除广告外总成本`
	,count(distinct PlatOrderNumber)/datediff('${NextStartDay}','${StartDay}') `日均订单数`
	,round( sum(case when ele_boxsku is not null then TotalGross/ExchangeUSD end ),2) `元素销售额`
from t_orde 
group by grouping sets ((),(department))
union
select '快百货' as department
	,round( sum((TotalGross-RefundAmount)/ExchangeUSD),2) `税后销售额`
	,round( sum(TotalExpend/ExchangeUSD)) `订单表总支出`
	,round( sum(ifnull((case when TransactionType='其他' and left(SellerSku,10)='ProductAds' 
		then AdvertisingCosts/ExchangeUSD end),0))) `其他类型统一扣除`
	,round( sum((TotalExpend/ExchangeUSD)-ifnull((case when TransactionType='其他' and left(SellerSku,10)='ProductAds' 
		then AdvertisingCosts/ExchangeUSD end),0)),2) `订单表除广告外总成本`
	,count(distinct PlatOrderNumber)/datediff('${NextStartDay}','${StartDay}') `日均订单数`
	,round( sum(case when ele_boxsku is not null then TotalGross/ExchangeUSD end ),2) `元素销售额`
from t_orde 
where t_orde.department regexp '快' 
union
select NodePathName
	,round( sum((TotalGross-RefundAmount)/ExchangeUSD),2) `税后销售额`
	,round( sum(TotalExpend/ExchangeUSD)) `订单表总支出`
	,round( sum(ifnull((case when TransactionType='其他' and left(SellerSku,10)='ProductAds' 
		then AdvertisingCosts/ExchangeUSD end),0))) `其他类型统一扣除`
	,round( sum((TotalExpend/ExchangeUSD)-ifnull((case when TransactionType='其他' and left(SellerSku,10)='ProductAds' 
		then AdvertisingCosts/ExchangeUSD end),0)),2) `订单表除广告外总成本`
	,count(distinct PlatOrderNumber)/datediff('${NextStartDay}','${StartDay}') `日均订单数`
	,round( sum(case when ele_boxsku is not null then TotalGross/ExchangeUSD end ),2) `元素销售额`
from t_orde where t_orde.department regexp '快' 
group by NodePathName
)

,t_fee_stat as (
select '快百货' as dep 
	,round( sum( FeeGross/ExchangeUSD )) `运费收入`
from t_orde 
left join ( select ordernumber  from import_data.daily_RefundOrders
	where RefundReason2 = '加急单延迟' group by ordernumber ) t on t_orde.ordernumber = t.ordernumber 
where t_orde.department regexp '快' and t.ordernumber is null 
union 
select case when department IS NULL THEN '公司' ELSE department END AS dep 
	,round( sum( FeeGross/ExchangeUSD )) `运费收入`
from t_orde 
left join ( select ordernumber  from import_data.daily_RefundOrders
	where RefundReason2 = '加急单延迟' group by ordernumber ) t on t_orde.ordernumber = t.ordernumber 
where t_orde.department regexp '快' and t.ordernumber is null 
group by grouping sets ((),(department))
)
	
	
,t_refd_stat as (
select case when department IS NULL THEN '公司' ELSE department END AS dep 
	,sum(RefundUSDPrice) `退款金额`
	,sum(case when !(RefundReason1='客户原因' and ShipDate = '2000-01-01') then RefundUSDPrice end) `非客户原因退款金额` 
from t_refd group by grouping sets ((),(department))
union
select '快百货' as department
	,sum(RefundUSDPrice) `退款金额`
	,sum(case when !(RefundReason1='客户原因' and ShipDate = '2000-01-01') then RefundUSDPrice end) `非客户原因退款金额` 
from t_refd where t_refd.department regexp '快' 
union
select NodePathName
	,sum(RefundUSDPrice) `退款金额`
	,sum(case when !(RefundReason1='客户原因' and ShipDate = '2000-01-01') then RefundUSDPrice end) `非客户原因退款金额` 
from t_refd group by NodePathName
)


,t_adse_stat as (
select case when department IS NULL THEN '公司' ELSE department END AS dep 
	,sum(AdSpend) `广告表广告花费` 
	,sum(AdSales) Adsale 
	,sum(AdSales_othersku) AdSales_othersku 
	,round(sum(AdSpend)/sum(AdSales),4) Acost
from t_adse group by grouping sets ((),(department))
union
select '快百货' as department ,sum(AdSpend) `广告表广告花费` 
	,sum(AdSales) Adsale 
	,sum(AdSales_othersku) AdSales_othersku 
	,round(sum(AdSpend)/sum(AdSales),4) Acost
from t_adse where t_adse.department regexp '快' 
union
select NodePathName,sum(AdSpend) `广告表广告花费` 
	,sum(AdSales) Adsale 
	,sum(AdSales_othersku) AdSales_othersku 
	,round(sum(AdSpend)/sum(AdSales),4) Acost
from t_adse group by NodePathName
)



,t_adse_new_lst as ( -- 新刊登链接广告
select case when t_adse.department IS NULL THEN '公司' ELSE t_adse.department END AS dep 
	,sum(AdSales) as new_lst_ad_sales
from t_adse 
join t_new_list on t_adse.ShopCode =t_new_list.ShopCode and t_adse.Asin =t_new_list.ASIN and t_adse.SellerSku = t_new_list.SellerSku 
group by grouping sets ((),(t_adse.department))
union 
select '快百货' as department 
	,sum(AdSales) as new_lst_ad_sales
from t_adse
join t_new_list on t_adse.ShopCode =t_new_list.ShopCode and t_adse.Asin =t_new_list.ASIN and t_adse.SellerSku = t_new_list.SellerSku 
where t_adse.department regexp '快'  
union 
select t_adse.NodePathName
	,sum(AdSales) as new_lst_ad_sales
from t_adse 
join t_new_list on t_adse.ShopCode =t_new_list.ShopCode and t_adse.Asin =t_new_list.ASIN and t_adse.SellerSku = t_new_list.SellerSku 
where t_adse.department regexp '快' 
group by t_adse.NodePathName
)




-- 坏账计算
-- select sum(FrozenAmountUs) `坏账金额` -- 使用实扣冻结额（美元） 作为计算坏账的金额字段
-- from import_data.BadDebtRate 
-- where ExceptionNotifyTime >= '2023-04-01' and ExceptionNotifyTime < '2023-05-01' -- 4月坏账(按异常通知时间)
-- and `Date` in ( select max(`Date`) Date from BadDebtRate ) -- 使用最新导入数据版本


-- ,t_ele_sale_over1000_monthly as (
-- select department as dep ,count(1) `月销超1000美金元素数量`
-- from (
-- 	select elem.name , ms.department ,round(sum(TotalGross/ExchangeUSD),2) as ele_sales
-- 	from import_data.wt_orderdetails wo 
-- 	join import_data.mysql_store ms on wo.ShopCode =ms.Code and wo.IsDeleted = 0 and ms.Department ='快百货'
-- 	join ( select name ,BoxSku as ele_boxsku from t_elem group by name ,BoxSku) elem on wo.BoxSku = elem.ele_boxsku -- 筛选元素品
-- 	where PayTime < '${NextStartDay}' and PayTime >=DATE_ADD('${StartDay}',interval -day('${StartDay}')+1 day) 
-- 	group by elem.name , ms.department
-- 	) tmp2
-- where ele_sales >= 1000 
-- group by department
-- )


-- step3 派生指标数据集
, t_merge as (
select t_key.dep 
	,t_sale_stat.`税后销售额` 
	,t_sale_stat.`订单表除广告外总成本` ,t_sale_stat.`日均订单数` ,t_sale_stat.`元素销售额`  
	,ifnull(t_refd_stat.`退款金额`,0) `退款金额` ,ifnull(t_refd_stat.`非客户原因退款金额`,0) `非客户原因退款金额`
	,t_adse_stat.`广告表广告花费` 
	,t_adse_stat.Adsale ,t_adse_stat.AdSales_othersku ,t_adse_stat.Acost
	,t_adse_new_lst.new_lst_ad_sales
	,`运费收入` 
-- 	,t_ele_sale_over1000_monthly.`月销超1000美金元素数量`
from t_key
left join t_adse_stat on t_key.dep = t_adse_stat.dep
left join t_refd_stat on t_key.dep = t_refd_stat.dep
left join t_sale_stat on t_key.dep = t_sale_stat.dep
left join t_adse_new_lst on t_key.dep = t_adse_new_lst.dep
left join t_fee_stat on t_key.dep = t_fee_stat.dep
-- left join t_ele_sale_over1000_monthly on t_key.dep = t_ele_sale_over1000_monthly.dep
)


-- step4 复合指标 = 派生指标叠加计算
select 
	'${NextStartDay}' `统计日期`
	,dep `团队` 
	,round(`税后销售额`-`退款金额`,2) `销售额`
	,round(`税后销售额`-`退款金额`+(`订单表除广告外总成本`-`广告表广告花费`),2) `利润额`
	,round( (`税后销售额`-`退款金额`+(`订单表除广告外总成本`-`广告表广告花费`))/(`税后销售额`-`退款金额`) ,3) `毛利率`
	,`税后销售额`
	,`退款金额`
	,`订单表除广告外总成本`
	,round(`日均订单数`) `日均订单数`
	,round(`退款金额`/`税后销售额`,4) `退款率`
	,round(`非客户原因退款金额`/`税后销售额`,4) `非客户原因退款率`
	,`非客户原因退款金额`
	,`广告表广告花费`
	,round(`广告表广告花费`/Adsale,4) `ACOS`
	,round(Adsale/`广告表广告花费`,4) `广告ROI`
	,round(`广告表广告花费`/(`税后销售额`-`退款金额`),4) `广告花费占比`
	,round(Adsale/(`税后销售额`-`退款金额`),4) `广告业绩占比`	
	,round(AdSales_othersku/(`税后销售额`-`退款金额`),4) `非广告产品业绩占比`	
	,round(new_lst_ad_sales/(`税后销售额`-`退款金额`),4) `新刊登广告业绩占比`	
-- 	,`坏账金额`
-- 	,`团队人数`
-- 	,`销售额人效`
-- 	,`利润额人效`
	,`元素销售额`
	,`运费收入`
	,round(`运费收入`/(`税后销售额`-`退款金额`),4) `运费收入占比`
	,round(`元素销售额`/(`税后销售额`-`退款金额`),4) `元素销售额占比`
-- 	,`月销超1000美金元素数量`
from t_merge
order by `团队` desc 