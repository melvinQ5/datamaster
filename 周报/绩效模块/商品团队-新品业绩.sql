-- 定义：终审时间在23年3月1号及以后的产品，在4-6月的业绩贡献，每天更新付款时间=昨天的业绩数据
-- 


with 
t_prod as ( -- 230301后终审
select SKU ,SPU ,DATE_ADD(DevelopLastAuditTime,interval - 8 hour) as DevelopLastAuditTime 
	,t.name ,t.NodePathName  ,t.Department 
from import_data.erp_product_products pp 
left join view_roles t on pp.DevelopUserName = t.name  and t.Department = '快百货' and t.ProductRole = '开发'
where DATE_ADD(DevelopLastAuditTime,interval - 8 hour)  >= '2023-04-01' and  DATE_ADD(DevelopLastAuditTime,interval - 8 hour) < '2023-07-01'
and IsMatrix = 0 and IsDeleted = 0 
and ProjectTeam ='快百货' a
)

,t_orde as (  -- 每周出单明细
select 
	left(PayTime,7) pay_month 
	,WEEKOFYEAR( paytime) pay_week 
	,to_date(PayTime) pay_date 
	,OrderNumber ,PlatOrderNumber ,TotalGross,TotalProfit,TotalExpend ,SaleCount
	,ExchangeUSD,TransactionType,SellerSku,RefundAmount,AdvertisingCosts,PublicationDate,Asin,BoxSku ,PurchaseCosts
	,paytime
-- 	,ms.department ,ms.split_part(NodePathNameFull,'>',2) dep2 ,ms.NodePathName  ,ms.SellUserName ,ms.Code as shopcode 
	,t.name ,t.NodePathName  ,t.Department 
from import_data.wt_orderdetails wo 
join t_prod t on wo.Product_Sku = t.sku 
join import_data.mysql_store ms on wo.shopcode=ms.Code 
	and paytime >= '2023-06-01' and paytime <'2023-07-01'
	and ms.Department = '快百货'
	and wo.IsDeleted=0
) 

,t_list as ( -- 23年内刊登链接
select wl.BoxSku ,wl.SKU ,PublicationDate ,IsDeleted  ,wl.ShopCode ,SellerSKU ,ASIN 
	,left( PublicationDate,7) pub_month
	,WEEKOFYEAR( PublicationDate) pub_week
	,to_date( PublicationDate) pub_date
	-- 	,ms.department ,ms.split_part(NodePathNameFull,'>',2) dep2 ,ms.NodePathName  ,ms.SellUserName ,ms.Code as shopcode 
	,t.name ,t.NodePathName  ,t.Department 
from wt_listing wl 
join t_prod t on wl.sku = t.sku 
join import_data.mysql_store ms on wl.ShopCode = ms.Code 
where 
	PublicationDate >=  '2023-03-01' and PublicationDate < '2023-07-01'
	and wl.IsDeleted = 0 
	and ms.Department = '快百货' 
-- 	and SellerSku not regexp '-BJ-|-BJ|BJ-|bJ|Bj|bj|BJ' -- 因为是新品时间范围 不限制刊登时间范围的
)

-- select count(1) from t_list

, t_list_stat as ( -- 表1 刊登计算
select 
-- 	case when NodePathName is not null and name is not null and pay_month is null and pay_week is null and pay_date is null then '开发组x人员' 
-- 		when NodePathName is not null and name is null and pay_month is null and pay_week is null and pay_date is null then '开发组' 
-- 		when NodePathName is null and SellUserName is null and pub_week is null then '团队' 
-- 		when NodePathName is not null and SellUserName is not null and pub_week is not null then '团队x小组x人员x刊登周' 
-- 		when NodePathName is not null and SellUserName is null and pub_week is not null then '团队x小组x刊登周' 
-- 		when NodePathName is null and SellUserName is null and pub_week is not null then '团队x刊登周' 
-- 		end as `分析维度`
-- 	,case when dep2 is null then '合计' else dep2 end as dep2
	case when NodePathName is null then '合计' else NodePathName end as NodePathName
	,case when name is null then '合计' else name end as name
-- 	,case when pub_week is null then '合计' else pub_week end as pub_week
	,pay_date
	,pay_week
	,pay_month
	,count(distinct BoxSku)  `刊登SKU数`
	,count(distinct concat(t_list.shopcode,t_list.SellerSku,t_list.Asin)) `刊登链接数`
from t_list
group by grouping sets(
	(NodePathName ,name ,pub_date)
	,(NodePathName ,name ,pay_week)
	,(NodePathName ,name ,pay_month)
	,(NodePathName ,pay_date)
	,(NodePathName ,pay_week)
	,(NodePathName ,pay_month)
	)
)
select * from t_list_stat


, t_list_sale_details as ( -- 表1 每条链接在每周的出单情况
select 
	t_list.dep2 ,t_list.NodePathName ,t_list.SellUserName ,t_list.sellersku ,t_list.shopcode ,t_list.pub_week 
	,od.boxsku ,od.pay_week ,od.salecount  ,od.TotalGross ,od.TotalProfit
from t_list 
join (
	select boxsku ,sellersku ,shopcode ,pay_week
		,sum(salecount) salecount
		,round( sum((TotalGross)/ExchangeUSD),2)  TotalGross
		,round( sum((TotalProfit)/ExchangeUSD),2)  TotalProfit
	from t_orde group by boxsku ,sellersku ,shopcode ,pay_week
	) od
	on t_list.shopcode = od.shopcode and t_list.sellersku = od.sellersku and t_list.sellersku = od.sellersku 
)
-- select sum(TotalGross) `销售额` from t_list_sale_details	

,t_list_sale_stat as (
select 
	case when NodePathName is not null and SellUserName is not null and pub_week is null then '小组x人员' 
		when NodePathName is not null and SellUserName is null and pub_week is null then '小组' 
		when NodePathName is null and SellUserName is null and pub_week is null then '团队' 
		when NodePathName is not null and SellUserName is not null and pub_week is not null then '团队x小组x人员x刊登周' 
		when NodePathName is not null and SellUserName is null and pub_week is not null then '团队x小组x刊登周' 
		when NodePathName is null and SellUserName is null and pub_week is not null then '团队x刊登周' 
		end as `分析维度`
	,case when dep2 is null then '合计' else dep2 end as dep2
	,case when NodePathName is null then '合计' else NodePathName end as NodePathName
	,case when SellUserName is null then '合计' else SellUserName end as SellUserName
	,case when pub_week is null then '合计' else pub_week end as pub_week
	,sum(salecount) `销量`  
	,sum(TotalGross) `销售额` 
	,sum(TotalProfit) `利润额` 
	,count(distinct concat(shopcode,sellersku)) `出单链接数`
	,count(distinct boxsku) `出单sku数`
from t_list_sale_details
group by grouping sets(
	(dep2 ,NodePathName ,SellUserName)
	,(dep2 ,NodePathName)
	,(dep2)
	,(dep2 ,NodePathName ,SellUserName,pub_week)
	,(dep2 ,NodePathName,pub_week)
	,(dep2 ,pub_week)
	)
)

, t_merge as (    
select 
	t_list_stat.`分析维度` 
	,t_list_stat.dep2 
	,t_list_stat.NodePathName 
	,t_list_stat.SellUserName  
	,t_list_stat.pub_week  
	,t_list_stat.`刊登SKU数`  
	,t_list_stat.`刊登链接数`  
	,t_list_sale_stat.`销量` 
	,t_list_sale_stat.`销售额` 
	,t_list_sale_stat.`利润额` 
	,t_list_sale_stat.`出单链接数` 
	,t_list_sale_stat.`出单sku数` 
from t_list_stat 
left join t_list_sale_stat 
on t_list_sale_stat.dep2 = t_list_stat.dep2 
	and t_list_sale_stat.NodePathName = t_list_stat.NodePathName
	and t_list_sale_stat.SellUserName = t_list_stat.SellUserName
	and t_list_sale_stat.pub_week = t_list_stat.pub_week 

)

-- select * from t_merge
-- where t_merge.SellUserName = '林丹娜'

-- 导出 部门-组员-周新刊登动销统计
select
	replace(concat(right('${StartDay}',5),'至',right(to_date(date_add('${NextStartDay}',-1)),5)),'-','') `刊登时间范围`
	,`分析维度` 
	,dep2 `团队`
	,NodePathName `小组`
	,t_merge.SellUserName `人员`
	,pub_week `刊登周`
	,`销量`
	,`销售额`
	,`利润额`
	,concat(round(`利润额`/`销售额`*100,2),'%') `毛利率`
	,`出单链接数`
	,`刊登链接数`
	,concat(round(`出单链接数`/`刊登链接数`*100,2),'%') `链接出单率`
	,`出单SKU数`
	,`刊登SKU数`
	,concat(round(`出单SKU数`/`刊登SKU数`*100,2),'%') `SKU出单率`
from t_merge
order by `分析维度`
