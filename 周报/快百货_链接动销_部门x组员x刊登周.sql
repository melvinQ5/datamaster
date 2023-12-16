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
 * 
 * 验证塞盒渠道SKU管理报告，按添加时间下载的数量 作为A 
 * ERP链接库的数量作为B，对比AB差异
 * 
 * 下载渠道SKU管理，剔除搬家、剔除复制（剔除塞盒渠道sku管理里面添加人不是“zhongxiang"且非BE/NL站点)
 * 
 * 按付款时间下载订单表，按店铺code归属筛选快百货
 * 
 * 在出单明细中给每条出单匹配刊登时间
 * 
 * ERP链接库，按店铺code归属筛选快百货
 * 业务需求：剔除搬家 =》通过sellersku中剔除BJ  not regexp '-BJ-|-BJ|BJ-' 
 * 业务需求：SQL数据源使用的是ERPlisting表，不含有添加入非钟祥的
 * 业务需求：使用渠道sku添加时间 =》使用listing表刊登时间
 * 复制SKU
 * 
 * 1、部门-组员表，增加列-周销量
2、当月新品出单SKU汇总（参考周出单SKU表）
3、当月新品出单渠道SKU明细（参考周SKU出单渠道表）
 * 
 */

-- ERP链接库，需要剔除添加人不是运营人员名字的，2月复制了大批的SKU

with 
t_orde as (  -- 每周出单明细
select 
	dd.week_num_in_year pay_week
    ,dd.week_begin_date as pay_week_begin_date
    ,OrderNumber ,PlatOrderNumber ,TotalGross,TotalProfit,TotalExpend ,SaleCount
	,ExchangeUSD,TransactionType,SellerSku,RefundAmount,AdvertisingCosts,Asin,BoxSku ,PurchaseCosts
	,paytime
	,ms.department ,split_part(ms.NodePathNameFull,'>',2) dep2 ,ms.NodePathName  
	,case when ms.SellUserName is null then '店铺无首选销售员' else ms.SellUserName end as SellUserName 
	,ms.Code as shopcode 
from import_data.wt_orderdetails wo
left join dim_date dd on date(paytime) = dd.full_date
join import_data.mysql_store ms on wo.shopcode=ms.Code 
	and paytime >= '${StartDay}' and paytime <'${NextStartDay}'
-- 	and paytime >= '2023-02-01' and paytime <'2023-03-01'
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
	,ms.department ,split_part(NodePathNameFull,'>',2) dep2 ,ms.NodePathName
	,case when ms.SellUserName is null then '店铺无首选销售员' else ms.SellUserName end as SellUserName
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
-- select count(1) from wt_listing  week_begin_date

, t_list_stat as ( -- 表1 刊登计算
select 
	case when NodePathName is not null and SellUserName is not null and pub_week_begin_date is null then '小组x人员'
		when NodePathName is not null and SellUserName is null and pub_week_begin_date is null then '小组'
		when NodePathName is null and SellUserName is null and pub_week_begin_date is null then '团队'
		when NodePathName is not null and SellUserName is not null and pub_week_begin_date is not null then '团队x小组x人员x刊登周'
		when NodePathName is not null and SellUserName is null and pub_week_begin_date is not null then '团队x小组x刊登周'
		when NodePathName is null and SellUserName is null and pub_week_begin_date is not null then '团队x刊登周'
		end as `分析维度`
	,case when dep2 is null then '合计' else dep2 end as dep2
	,case when NodePathName is null then '合计' else NodePathName end as NodePathName
	,case when SellUserName is null then '合计' else SellUserName end as SellUserName
	,case when pub_week_begin_date is null then '合计' else pub_week_begin_date end as pub_week_begin_date
	,concat(ifnull(dep2,''),ifnull(NodePathName,''),ifnull(SellUserName,''),ifnull(pub_week_begin_date,'')) tbcode
	,count(distinct BoxSku)  `刊登SKU数`
	,count(distinct concat(t_list.shopcode,t_list.SellerSku,t_list.Asin)) `刊登链接数`
from t_list
group by grouping sets(
	(dep2 ,NodePathName ,SellUserName)
	,(dep2 ,NodePathName)
	,(dep2)
	,(dep2 ,NodePathName ,SellUserName,pub_week_begin_date)
	,(dep2 ,NodePathName,pub_week_begin_date)
	,(dep2 ,pub_week_begin_date)
	)
)
-- select * from t_list_stat 

, t_list_sale_details as ( -- 表1 每条链接在每周的出单情况
select 
	t_list.dep2 ,t_list.NodePathName ,t_list.SellUserName ,t_list.sellersku ,t_list.shopcode ,t_list.pub_week_begin_date 
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
	case when NodePathName is not null and SellUserName is not null and pub_week_begin_date is null then '小组x人员' 
		when NodePathName is not null and SellUserName is null and pub_week_begin_date is null then '小组' 
		when NodePathName is null and SellUserName is null and pub_week_begin_date is null then '团队' 
		when NodePathName is not null and SellUserName is not null and pub_week_begin_date is not null then '团队x小组x人员x刊登周' 
		when NodePathName is not null and SellUserName is null and pub_week_begin_date is not null then '团队x小组x刊登周' 
		when NodePathName is null and SellUserName is null and pub_week_begin_date is not null then '团队x刊登周' 
		end as `分析维度`
	,case when dep2 is null then '合计' else dep2 end as dep2
	,case when NodePathName is null then '合计' else NodePathName end as NodePathName
	,case when SellUserName is null then '合计' else SellUserName end as SellUserName
	,case when pub_week_begin_date is null then '合计' else pub_week_begin_date end as pub_week_begin_date
	,concat(ifnull(dep2,''),ifnull(NodePathName,''),ifnull(SellUserName,''),ifnull(pub_week_begin_date,'')) tbcode 
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
	,(dep2 ,NodePathName ,SellUserName,pub_week_begin_date)
	,(dep2 ,NodePathName,pub_week_begin_date)
	,(dep2 ,pub_week_begin_date)
	)
)

, t_merge as (    
select 
	t_list_stat.`分析维度` 
	,t_list_stat.dep2 
	,t_list_stat.NodePathName 
	,t_list_stat.SellUserName  
	,t_list_stat.pub_week_begin_date  
	,dd.week_num_in_year pub_week 
	,t_list_stat.`刊登SKU数`  
	,t_list_stat.`刊登链接数`  
	,t_list_sale_stat.`销量` 
	,t_list_sale_stat.`销售额` 
	,t_list_sale_stat.`利润额` 
	,t_list_sale_stat.`出单链接数` 
	,t_list_sale_stat.`出单sku数` 
from t_list_stat 
left join t_list_sale_stat on t_list_sale_stat.tbcode = t_list_stat.tbcode 
left join (select distinct year ,week_num_in_year ,week_begin_date  from dim_date) dd on t_list_stat.pub_week_begin_date = dd.week_begin_date
)

-- select * from t_merge



-- 导出 部门-组员-周新刊登动销统计 week_begin_date

select
	replace(concat(right(date('${StartDay}'),5),'至',right(to_date(date_add('${NextStartDay}',-1)),5)),'-','') `刊登时间范围`
	,`分析维度` 
	,dep2 `团队`
	,NodePathName `小组`
	,t_merge.SellUserName `人员`
	,pub_week `刊登周`
	,pub_week_begin_date `当周周一`
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
	,round(`销售额`/ `出单链接数`,1) `出单链接单产` 
	,round(`销售额`/ `出单sku数`,1) `出单sku单产` 
from t_merge
order by `分析维度`