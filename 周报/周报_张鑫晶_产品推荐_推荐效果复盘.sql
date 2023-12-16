
with 
push_sku as (
select BoxSku ,SPU AS push_rule
from import_data.JinqinSku js where Monday = '2023-03-03' and Spu REGEXP '产品推荐'
)

, t_orde as (  -- 推荐后指定日期的出单明细
select WEEKOFYEAR( paytime) pay_week ,OrderNumber ,PlatOrderNumber ,TotalGross,TotalProfit,TotalExpend ,SaleCount
	,ExchangeUSD,TransactionType,SellerSku,RefundAmount,AdvertisingCosts,PublicationDate,Asin ,wo.BoxSku ,PurchaseCosts
	,paytime
	,ms.department ,ms.split_part(NodePathNameFull,'>',2) dep2 ,ms.NodePathName  ,ms.SellUserName ,ms.Code as shopcode 
from import_data.wt_orderdetails wo 
join push_sku on wo.BoxSku = push_sku.BoxSku
join import_data.mysql_store ms on wo.shopcode=ms.Code 
	and paytime >= '${StartDay}' and paytime <'${NextStartDay}'
	and ms.Department = '快百货'
	and wo.IsDeleted=0
) 

,t_list as ( -- 23年内刊登链接
select wl.BoxSku ,SKU ,PublicationDate ,IsDeleted  ,wl.ShopCode ,SellerSKU ,ASIN 
	, WEEKOFYEAR( PublicationDate) pub_week
	,ms.department ,ms.split_part(NodePathNameFull,'>',2) dep2 ,ms.NodePathName  ,ms.SellUserName
from wt_listing wl 
join push_sku on wl.BoxSku = push_sku.BoxSku
join import_data.mysql_store ms on wl.ShopCode = ms.Code 
	and wl.IsDeleted = 0 and ms.Department = '快百货' 
where PublicationDate >= '${StartDay}' and PublicationDate <'${NextStartDay}' and length(SKU) > 0 
)

, t_sale_src as ( -- 表1 数据明细 每个订单的每条链接
select case when tmp.pub_week is null and TransactionType != '其他' then '之前年度刊登' else tmp.pub_week end pub_week
	,tmp.PublicationDate
	,t_orde.pay_week
	,t_orde.sellersku ,t_orde.shopcode,t_orde.asin
	,OrderNumber ,PlatOrderNumber ,TotalGross,TotalProfit,TotalExpend ,salecount ,paytime
	,ExchangeUSD,TransactionType ,RefundAmount,AdvertisingCosts,PurchaseCosts
	,dep2 ,SellUserName ,boxsku 
from t_orde
left join ( select shopcode ,sellersku ,asin , pub_week,PublicationDate from t_list group by shopcode , sellersku ,asin ,pub_week,PublicationDate ) tmp 
	on t_orde.shopcode = tmp.shopcode and t_orde.sellersku = tmp.sellersku and t_orde.asin =tmp.asin 
)

, t_sale_stat as ( -- 表1 出单计算
select 
	boxsku 
	,sum(salecount) `出单SKU件数`
	,round( sum((TotalGross)/ExchangeUSD),2)  `销售额`
	,round( sum((TotalProfit)/ExchangeUSD),2)  `利润额`
	,round( (sum((TotalProfit)/ExchangeUSD))/sum((TotalGross)/ExchangeUSD) ,3) `毛利率`
	,count(distinct concat(shopcode,SellerSku,Asin)) `出单链接数`
	,count(distinct BoxSku)  `出单SKU数`
-- 	,avg(`出单天数`) `平均出单天数`
from t_sale_src
group by boxsku 
)
-- select * from t_sale_stat


, t_list_stat as ( -- 表1 刊登计算
select dep2
	, case when SellUserName is null then '合计' else SellUserName end SellUserName
	, case when pub_week is null then '合计' else pub_week end  pub_week
	,count(distinct BoxSku)  `上架SKU数`
	,count(distinct concat(t_list.shopcode,t_list.SellerSku,t_list.Asin)) `上架链接数`
from t_list
group by grouping sets ((dep2,pub_week),(dep2 ,SellUserName,pub_week) )
)


, t_merge as (    
select t_sale_stat.* ,t_list_stat.`上架SKU数` ,t_list_stat.`上架链接数`
from t_sale_stat 
left join t_list_stat on t_sale_stat.dep2 = t_list_stat.dep2 and t_sale_stat.SellUserName = t_list_stat.SellUserName
and t_sale_stat.pub_week = t_list_stat.pub_week 
)

-- 导出 部门-组员-周新刊登动销统计
select
	dep2 `团队`
	,SellUserName `人员`
	,pub_week `刊登周`
	,pay_week `出单周`
	,`销售额`
	,`利润额`
	,`毛利率`
	,`出单链接数`
	,`上架链接数`
	,round(`出单链接数`/`上架链接数`,4) `链接出单率`
	,`出单SKU数`
	,`上架SKU数`
	,round(`出单SKU数`/`上架SKU数`,4) `SKU出单率`
	,`平均SKU出单数`
-- 	,`刊登天数` -- 刊登时间 - 推荐时间？ 
from t_merge 
where `销售额` >0 -- 排除一些多余关联组合  
order by dep2 , SellUserName ,pub_week ,pay_week 
