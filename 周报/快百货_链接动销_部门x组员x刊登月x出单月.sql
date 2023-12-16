/*
 * 每周刊登链接动销快照
 * 维度：部门 x 组员 x 刊登周 × 出单周
 * 指标：财务结果及链接动销指标
 *
 * 参考业务EXCEL操作，使用大数据平台数据源处理
 * 业务操作逻辑如下：
 * sheet订单利润报表
 * 		下载sheet订单利润报表 (按付款时间下载2月)
 * 		增加关联字段 concat(销售账号,渠道SKU)
 * sheet渠道SKU
 * 		下载塞盒\自定义报告\渠道sku管理（按添加时间下载2月）
 * 		增加关联字段 concat(销售账号,渠道SKU)
 * 		增加维度字段 出单listing，用于标识是否出单
 * 		增加指标字段 SUMIF(订单利润报表!$E:$E,$E1,订单利润报表!Y:Y) as 总收入
 * 		根据订单利润报表的数据计算每条链接的指标
 * 按三张需求的各自的维度聚合指标
 *
 * ERP链接库，按店铺code归属筛选快百货
 * 业务需求：剔除搬家 =》通过sellersku中剔除BJ  not regexp '-BJ-|-BJ|BJ-'
 * 业务需求：SQL数据源使用的是ERPlisting表，不含有添加入非钟祥的
 * 业务需求：使用渠道sku添加时间 =》使用listing表刊登时间
 * 复制SKU
 */


with 
t_orde as (  -- 每周出单明细
select 
	WEEKOFYEAR( paytime) pay_week 
	,MONTH( paytime)  pay_month
	,year(paytime) pay_year
	,OrderNumber ,PlatOrderNumber ,TotalGross,TotalProfit,TotalExpend ,SaleCount
	,ExchangeUSD,TransactionType,SellerSku,RefundAmount,AdvertisingCosts,Asin,BoxSku ,PurchaseCosts
	,paytime
	,ms.department ,ms.split_part(NodePathNameFull,'>',2) dep2 ,ms.NodePathName  
	,case when ms.SellUserName is null then '店铺无首选销售员' else ms.SellUserName end as SellUserName 
	,ms.Code as shopcode 
from import_data.wt_orderdetails wo
join import_data.mysql_store ms on wo.shopcode=ms.Code 
	and paytime >= '${StartDay}' and paytime <'${NextStartDay}'
-- 	and paytime >= '2022-01-01' and paytime <'2023-04-01'
	and ms.Department = '快百货'
	and wo.IsDeleted=0
) 


,t_list as ( -- 23年内刊登链接
select distinct a.*
    ,dd.week_num_in_year pub_week
    ,dd.week_begin_date as pub_week_begin_date
from (
select wl.BoxSku ,wl.SKU ,MinPublicationDate_new as MinPublicationDate ,IsDeleted  ,wl.ShopCode ,SellerSKU ,wl.ASIN
    ,MONTH( MinPublicationDate_new) pub_month
	,year( MinPublicationDate_new) pub_year
	,ms.department ,case when NodePathName regexp  '成都' then '成都' else '泉州' end as dep2  ,ms.NodePathName
--	,case when ms.SellUserName is null then '店铺无首选销售员' else ms.SellUserName end as SellUserName
    ,Publisher as SellUserName
from wt_listing wl
left join
    ( select asin, MarketType ,min(PublicationDate) as MinPublicationDate_new
    from wt_listing wl join import_data.mysql_store ms on wl.ShopCode = ms.Code and ms.department = '快百货' group by asin ,MarketType ) t1
    on wl.asin = t1.ASIN and wl.MarketType =t1.MarketType
join import_data.mysql_store ms on wl.ShopCode = ms.Code
where
	MinPublicationDate_new>= '${StartDay}' and MinPublicationDate_new <'${NextStartDay}'
	-- and wl.IsDeleted = 0
	and ms.Department = '快百货'
	and SellerSku not regexp '-BJ-|-BJ|BJ-|bJ|Bj|bj|BJ'
) a
left join dim_date dd on date(a.MinPublicationDate) = dd.full_date
)

-- select count(1) from t_list

, t_list_stat as ( -- 表1 刊登计算
select 
	dep2 , SellUserName  ,NodePathName ,pub_year ,pub_month
	,count(distinct BoxSku)  `刊登SKU数`
	,count(distinct concat(t_list.shopcode,t_list.SellerSku,t_list.Asin)) `刊登链接数`
from t_list
group by dep2 ,SellUserName ,NodePathName ,pub_year ,pub_month
)

, t_list_sale_details as ( -- 表1 每条链接在每周的出单情况
select 
	t_list.dep2 ,t_list.SellUserName ,t_list.sellersku ,t_list.shopcode ,pub_year ,pub_month 
	,od.boxsku  ,pay_year ,pay_month ,od.salecount  ,od.TotalGross ,od.TotalProfit
from t_list 
join (
	select boxsku ,sellersku ,shopcode  ,pay_year ,pay_month
		,sum(salecount) salecount
		,round( sum((TotalGross)/ExchangeUSD),2)  TotalGross
		,round( sum((TotalProfit)/ExchangeUSD),2)  TotalProfit
	from t_orde group by boxsku ,sellersku ,shopcode ,pay_year ,pay_month
	) od
	on t_list.shopcode = od.shopcode and t_list.sellersku = od.sellersku
)
-- select sum(TotalGross) `销售额` from t_list_sale_details	
	
,t_list_sale_stat as (
select dep2  , SellUserName  ,pay_year ,pay_month  ,pub_year ,pub_month 
	,sum(salecount) `销量`  
	,sum(TotalGross) `销售额` 
	,sum(TotalProfit) `利润额` 
	,count(distinct concat(shopcode,sellersku)) `出单链接数`
	,count(distinct boxsku) `出单sku数`
from t_list_sale_details
group by dep2 ,SellUserName ,pay_year ,pay_month  ,pub_year ,pub_month 
)

, t_merge as (    
select 
	t_list_stat.dep2 
	,t_list_stat.NodePathName
	,t_list_stat.SellUserName
	,pay_year ,pay_month
	,t_list_stat.pub_year ,t_list_stat.pub_month 
	,t_list_stat.`刊登SKU数`  
	,t_list_stat.`刊登链接数`  
	,t_list_sale_stat.`销量` 
	,t_list_sale_stat.`销售额` 
	,t_list_sale_stat.`利润额` 
	,t_list_sale_stat.`出单链接数` 
	,t_list_sale_stat.`出单sku数` 
from t_list_stat 
left join t_list_sale_stat 
on t_list_sale_stat.dep2 = t_list_stat.dep2 and t_list_sale_stat.SellUserName = t_list_stat.SellUserName
and t_list_sale_stat.pub_year = t_list_stat.pub_year 
and t_list_sale_stat.pub_month = t_list_stat.pub_month 
)
-- select * from t_merge

-- 导出 部门-组员-周新刊登动销统计
select

	dep2 `团队`
    ,case when length(t_merge.SellUserName) = 0 then '链接数据源无刊登人记录' else t_merge.SellUserName end as `链接刊登人员`
	,t_merge.NodePathName `店铺当前小组`
	,pay_year `出单年`
	,pay_month  `出单月`
	,pub_year `刊登年`
	,pub_month `刊登月`
	,`销量`
	,round(`销售额`,2) 销售额
	,round(`利润额`,2) 利润额
	,concat(round(`利润额`/`销售额`*100,2),'%') `毛利率`
	,`出单链接数`
	,`刊登链接数`
	,concat(round(`出单链接数`/`刊登链接数`*100,2),'%') `链接出单率`
	,`出单SKU数`
	,`刊登SKU数`
	,concat(round(`出单SKU数`/`刊登SKU数`*100,2),'%') `SKU出单率`
	,round(`销售额`/ `出单链接数`,1) `出单链接单产` 
	,round(`销售额`/ `出单sku数`,1) `出单sku单产` 
from t_merge
where !(pay_year = pub_year and pay_month < pub_month) 
order by dep2 ,NodePathName , t_merge.SellUserName ,pay_year ,pay_month  ,pub_year ,pub_month 

-- 


