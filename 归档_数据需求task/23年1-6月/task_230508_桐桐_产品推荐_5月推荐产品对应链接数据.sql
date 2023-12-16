
with t_prod as ( -- 桐桐根据手工表提供名单
select c2 as sku ,c3 as boxsku
from manual_table mt where c1 = '产品推荐确定的400个品230508'
)

-- 链接
,t_list as ( -- 新品链接
select  SellerSKU ,ShopCode ,asin 
	, site
	, accountcode
	, NodePathName 
	, split_part(ms.NodePathNameFull,'>',2) dep2
	, split_part(ms.accountcode,'-',1) 账号简码
	,case when ms.SellUserName is null then '店铺无首选销售员' else ms.SellUserName end as SellUserName
	, wl.SPU ,wl.SKU ,MinPublicationDate ,MarketType 
	,case when ListingStatus = 1 and ms.ShopStatus = '正常' then '在线' else '非在线' end as 链接状态
	,t_prod.boxsku 
from import_data.wt_listing wl 
join import_data.mysql_store ms on wl.ShopCode = ms.Code 
join t_prod on wl.sku = t_prod.sku 
where 
-- 	MinPublicationDate>= date_add('${NextStartDay}' ,interval - 3 month) and MinPublicationDate <'${NextStartDay}' 
	wl.IsDeleted = 0 
	and ms.Department = '快百货' 
)
-- select count(1) from t_list where 链接状态 = '在线'

-- 广告
,t_ad as ( -- 广告明细
select  t_list.sku, asa.AdActivityName ,campaignBudget ,cost ,ExchangeUSD ,TotalSale7Day , asa.TotalSale7DayUnit , asa.Clicks, asa.Exposure
	,ROAS ,Acost as ACOS 
	, asa.CreatedTime, asa.ShopCode ,asa.Asin  ,asa.SellerSKU 
	,t_list.site
	, NodePathName 
	, SellUserName
from t_list
join import_data.AdServing_Amazon asa on t_list.ShopCode = asa.ShopCode and t_list.SellerSKU = asa.SellerSKU 
where asa.CreatedTime >= date_add('${NextStartDay}' ,interval - 3 month) and asa.CreatedTime  <'${NextStartDay}' 
)
 
-- 订单  '`wo`.`Product_SPU`' 
-- 处理 组合sku、复制sku、退回账号
,tb as ( -- 快百货归还财务的600个账号
select c2 as arr from  manual_table mt where c1 = '快百货退回财务账号0427'
)

,rela as (
select *
from 
	(select 
		epp1.sku as ori_sku ,epp1.BoxSKU as ori_boxsku ,epp1.ProjectTeam as ori_team 
		,epp2.sku as new_sku ,epp2.BoxSKU as new_boxsku ,epp2.ProjectTeam as new_team 
	from import_data.erp_product_product_copy_relations eppcr 
	left join import_data.erp_product_products epp1 on eppcr.OrigProdId = epp1.Id and epp1.IsMatrix =0
	left join import_data.erp_product_products epp2 on eppcr.NewProdId = epp2.Id and epp2.IsMatrix =0
	where eppcr.IsDeleted = 0 and epp1.Id is not null -- 去掉母体复制关系的记录
	) tb
where ori_team <> '快百货' and new_team = '快百货'  -- 从其他部门复制到快百货的sku
)

-- 销售额S1 未扣税未扣退款
,od_pre as ( -- 三部分订单记录：快百货现有账号出单(出单sku本身包括复制关系里的源SKU) + 快百货退回财务账号(出单sku本身包括复制关系里的源SKU) 
select BoxSku, paytime ,SaleCount ,totalgross + TaxGross as totalgross ,totalprofit ,GroupSku ,GroupSkuNumber ,PlatOrderNumber ,ExchangeUSD ,wo.Site 
	,wo.shopcode ,wo.SellerSku ,Product_SPU ,Product_Sku
	,case when GroupSkuNumber > 0 then GroupSku else BoxSku end as targetsku 		
	,case when GroupSkuNumber > 0 then '组合出单' else '非组合出单' end as isgroup_pre 		
from import_data.wt_orderdetails wo 
join mysql_store ms on ms.Code = wo.shopcode 
-- join rela on wo.BoxSku = rela.ori_boxsku  -- 临时导表 复制关系
where wo.IsDeleted = 0 and OrderStatus != '作废' and ms.Department = '快百货' and TransactionType = '付款'
	and PayTime >= date_add('${NextStartDay}' ,interval - 3 month) and PayTime < '${NextStartDay}' 
union 
select BoxSku, paytime ,SaleCount  ,totalgross + TaxGross as totalgross ,totalprofit ,GroupSku ,GroupSkuNumber ,PlatOrderNumber ,ExchangeUSD ,wo.Site 
	,wo.shopcode ,wo.SellerSku ,Product_SPU ,Product_Sku
	,case when GroupSkuNumber > 0  then GroupSku else BoxSku end  as targetsku 
	,case when GroupSkuNumber > 0 then '组合出单' else '非组合出单' end as isgroup_pre 	
from import_data.wt_orderdetails wo 
join tb on wo.shopcode = tb.arr -- 快百货归还财务的600个账号
-- join rela on wo.BoxSku = rela.ori_boxsku  -- 临时导表 复制关系
where wo.IsDeleted = 0 and OrderStatus != '作废' and TransactionType = '付款' 
	and PayTime >= date_add('${NextStartDay}' ,interval - 3 month) and PayTime < '${NextStartDay}' 
)

, boxsku_2_groupsku as ( -- 单独处理如果 子体SKU直接同编码转变为组合SKU，详情可查订单表 boxsku in (4302766,4350836)
select targetsku 
	, case when isgroup regexp '组合出单' then '组合出单' else '非组合出单' end as isgroup -- 只要曾有过组合出单，即是为组合出单
from (select targetsku ,GROUP_CONCAT(isgroup_pre) isgroup from od_pre group by targetsku) tmp
)

,od as (
select a.targetsku ,BoxSku, b.isgroup , paytime ,SaleCount ,totalgross ,totalprofit ,GroupSku  ,site  ,ShopCode ,SellerSKU ,Product_SPU ,Product_Sku
	,GroupSkuNumber ,PlatOrderNumber ,ExchangeUSD 
from od_pre a join boxsku_2_groupsku b on a.targetsku = b.targetsku
)

,t_orde as (  -- 新刊登链接对应订单
select 
	t_list.SellerSKU ,t_list.ShopCode ,t_list.asin ,od.boxsku 
	,PlatOrderNumber ,TotalGross,TotalProfit ,salecount
	,ExchangeUSD
	,Product_SPU as SPU 
	,Product_Sku  as SKU 
	,PayTime
	,t_list.site
	, NodePathName 
	, SellUserName
from od
join t_list on t_list.ShopCode = od.ShopCode and t_list.SellerSKU = od.SellerSKU -- 只看快百货 新刊登新品链接的对应订单
)
-- select * from t_orde where boxsku = 2362609 

,t_orde_stat as (
select shopcode  ,sellersku  
	,round(sum( TotalGross/ExchangeUSD ),2) TotalGross
	,round(sum( TotalProfit/ExchangeUSD ),2) TotalProfit
	,round(sum( TotalProfit/TotalGross ),2) ProfitRate
	,round(sum( salecount ),2) salecount
from t_orde 
group by shopcode  ,sellersku  
)

, t_ad_stat as (
select tmp.* 
	, round(ad_sku_Clicks/ad_sku_Exposure,4) as `广告点击率` 
	, round(ad_sku_TotalSale7DayUnit/ad_sku_Clicks,6) as `广告转化率`
	, round(ad_TotalSale7Day/ad_Spend,4) as `ROAS`
	, round(ad_Spend/ad_TotalSale7Day,4) as `ACOS`
	, round(ad_Spend/ad_sku_Clicks,4) as `CPC`
from 
	( select shopcode  ,sellersku 
		-- 曝光量
		, round(sum( Exposure )) as ad_sku_Exposure
		-- 广告花费
		, round(sum( cost*ExchangeUSD),2) as ad_Spend
		-- 广告销售额
		, round(sum( TotalSale7Day ),2) as ad_TotalSale7Day
		-- 广告销量	
		, round(sum( TotalSale7DayUnit ),2) as ad_sku_TotalSale7DayUnit
		-- 点击量
		, round(sum( Clicks )) as ad_sku_Clicks
		from t_ad  group by shopcode  ,sellersku 
	) tmp  
)

select 
	t_list.sku
	,ta.boxsku
	,t_list.SellerSKU 
	,t_list.ShopCode 
	,链接状态
	,asin 
	,accountcode 
	,账号简码
	,site 站点
	,dep2 销售部门
	,NodePathName 销售团队
	,SellUserName 首选业务员
	,TotalGross 销售额_近3月
	,TotalProfit 利润额_近3月
	,ProfitRate 利润率_近3月
	,salecount 销量_近3月
	,CPC
	,ACOS
	,ad_Spend 广告花费
	,ad_TotalSale7Day 广告业绩
	,广告转化率
	,广告点击率
	,ad_sku_Clicks as 点击量
	,ad_sku_Exposure as 曝光量
	,case when round(ad_TotalSale7Day/TotalGross,2) >1 then 1 else round(ad_TotalSale7Day/TotalGross,2) end  广告业绩占比
-- 	,round(ad_TotalSale7Day/TotalGross,2)  广告业绩占比
from t_list
left join (
	select sku ,boxsku ,case when TortType is null then '未标记' else TortType end TortType ,Festival ,Artist ,Editor 
		,ProductName ,DevelopUserName ,to_date(DATE_ADD(DevelopLastAuditTime,interval - 8 hour)) as DevelopLastAuditTime
		,case when wp.ProductStatus = 0 then '正常'
			when wp.ProductStatus = 2 then '停产'
			when wp.ProductStatus = 3 then '停售'
			when wp.ProductStatus = 4 then '暂时缺货'
			when wp.ProductStatus = 5 then '清仓'
			end as ProductStatus
		from import_data.wt_products wp
		where IsDeleted =0  and ProjectTeam='快百货'
	) ta on t_list.sku =ta.sku 
left join t_ad_stat on  t_list.ShopCode = t_ad_stat.ShopCode and t_list.SellerSKU = t_ad_stat.SellerSKU 
left join t_orde_stat on  t_list.ShopCode = t_orde_stat.ShopCode and t_list.SellerSKU = t_orde_stat.SellerSKU 
where 链接状态 = '在线'
order by sku , 销售部门 , 销售团队 ,首选业务员