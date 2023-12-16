/*
背景：链接清理 风控
公司总计：300条
单组总计：70条
删除标准：未出单按刊登时间从远到近删除，删到300/70条
①保留22-23年出单的链接
②UK/DE/FR/ES/IT/US/CA/MX 单站点7条；AU/SE/NL/PL/JP单站点5条
③近8周有访客>近60天广告有点击>近60天有曝光>刊登时间新优于旧

step1 制定清理规则
step2 跑数测试 首先每组拿出来一条在线条数最多的一个SKU进行测试跑
*/

with 
t_prod as ( -- 筛选老品
select sku ,Festival
from wt_products wp 
where IsDeleted = 0  
	and ProjectTeam = '快百货' 
	and Festival is not null -- 季节品
	and date_add(DevelopLastAuditTime , interval -8 hour) < '2023-01-01'
	and ProductStatus != 2 
-- 	and sku = 1059049.03
)

,t_vist as ( 
select ShopCode ,ChildAsin ,round(sum(TotalCount*FeaturedOfferPercent/100),1) `近8周访客数`
from import_data.ListingManage lm 
where Monday >= '2023-02-06' and Monday <= '2023-03-27' and ReportType = '周报'
group by ShopCode ,ChildAsin 
)

,t_list as ( -- 确定待删除链接范围
select wl.BoxSku ,wl.SKU ,to_date(PublicationDate) `刊登时间` ,wl.ShopCode ,wl.SellerSKU ,ASIN 
	,ms.department ,split_part(NodePathNameFull,'>',2) dep2 ,ms.NodePathName  ,ms.SellUserName `首选业务员` ,ms.Site 
	,ms.AccountCode 
	,wp.Festival `季节节日`
	,`近8周访客数`
from wt_listing wl -- 因为最终输出落到具体sku,所以不需要使用erp表
join import_data.mysql_store ms on wl.ShopCode = ms.Code 
join t_prod wp on wl.sku = wp.Sku -- 筛选目标老品
left join t_vist lm on lm.ShopCode = wl.shopcode and lm.ChildAsin = wl.ASIN  
where 
	wl.IsDeleted = 0 and wl.ListingStatus = 1
	and ms.Department = '快百货'
	and ms.ShopStatus = '正常'
	and PublicationDate < '2023-01-01'
)

,t_orde as (  
select 
	SellerSku,Asin,Product_Sku as sku 
	,OrderNumber ,PlatOrderNumber ,SaleCount
	,paytime ,OrderStatus 
	,PublicationDate 
	,ms.department ,ms.split_part(NodePathNameFull,'>',2) dep2 ,ms.NodePathName  ,ms.SellUserName ,ms.Code as shopcode 
from import_data.wt_orderdetails wo 
join import_data.mysql_store ms on wo.shopcode=ms.Code 
	and paytime >= '2022-01-01'and paytime <'2023-04-11'
	and ms.Department = '快百货'
	and wo.IsDeleted=0
)

,t_orde_list as ( -- 出单链接
select ROW_NUMBER()over(partition by NodePathName ,sku order by `2201-230410销量` desc ) `2201-230410销量排序`
	,t.*
from (
	select NodePathName ,sku ,shopcode ,sellersku ,PublicationDate
		, sum( case when paytime >= '2022-01-01'and paytime <'2023-04-11' then salecount end ) `2201-230410销量`
	from t_orde 
	where sku is not null 
	group by NodePathName ,sku ,shopcode ,sellersku ,PublicationDate HAVING sum(salecount) > 0  
	) t 
)

-- 开始标注
,res_list_1 as ( -- 标记出单链接
select
	count(mark1) over(partition by NodePathName ,sku ) `mark1已标注链接数` -- 为了下一步计算同账号链接：70-已标记数
	,tc.*
from (
	select 
		case when `2201-230410销量` > 0 and `2201-230410销量排序` <=70  then '保留_出单链接' end as mark1 
		,tb.`2201-230410销量` 
		,ta.*
	from t_list ta left join t_orde_list tb 
		on ta.sellersku = tb.sellersku and ta.shopcode = tb.shopcode 
	-- where accountcode = 'QB-NA' -- 一个出单账号
	) tc 
)
	
,res_list_2 as (  -- 标记 上一步保留链接中同账号所有链接
select 
	case when tc.`刊登时间排序` <= 70 - `mark1已标注链接数` then '保留_同账号链接' end as mark2
	,`刊登时间排序`
	, `mark1已标注链接数`
	,res_list_1.*
from res_list_1 
left join ( -- 按刊登时间降序，并计算按上一步已标记数
	select 
		ta.sellersku ,ta.shopcode  
		,ROW_NUMBER() over(partition by NodePathName ,sku order by `刊登时间` desc ) `刊登时间排序`
	from res_list_1 ta 
	join ( -- 筛选上一步未标记保留的 同账号链接
		select AccountCode from res_list_1 where mark1 = '保留_出单链接' group by AccountCode 
		) tb on ta.AccountCode = tb.AccountCode
	where ta.mark1 is null -- 选出同账号 且还没标注保留的链接
	) tc 
	on res_list_1.sellersku = tc.sellersku and res_list_1.shopcode = tc.shopcode
)


select * from res_list_2

-- 查看截至目前，每个团队，每个sku已保留链接数 和 总在线链接数
, t_stat as (
select 
	 NodePathName ,sku 
	,count(COALESCE(mark1,mark2))  `mark1_2已标注uk链接数` 
	,count(1) `总在线链接`
from res_list_2
group by NodePathName ,sku 
)

-- 截至目前，已保留了出单链接、出单链接的同账号链接。如果已经超过70的链接不管，对于不够70条的链接，按近60天有点击来取
-- 单站点不超过7条也想不管

, t_stat_list as ( -- 找出少于70条的链接的 sku+团队，然后筛出总表中还没有标注的链接，按刊登点击量近时间往下取
select NodePathName ,sku  from t_stat where  `mark1_2已标注uk链接数`  < 70  
)


select 
from res_list_2 ta 
join t_stat_list tb on ta.nodepathname = tb.nodepathname  and ta.sku = tb.sku  
where 

-- select 
-- from res_list_2
-- where COALESCE(mark1,mark2) is null 



-- select * from t_stat

-- ,t_UK as ( 
-- case when tc.`刊登时间排序` <= 70 - `mark1_2已标注链接数` then '保留_同账号链接' end as mark2
-- )

-- ,t_ad_stat as ( 
-- select asa.ShopCode ,asa.SellerSKU , sum(asa.Clicks) `近60天广告点击量` , sum(asa.Exposure) `近60天广告曝光量`
-- from t_list
-- join import_data.AdServing_Amazon asa on t_list.ShopCode = asa.ShopCode and t_list.SellerSKU = asa.SellerSKU 
-- where CreatedTime >= date_add('2023-04-07',interval -60 day) and CreatedTime < '2023-04-07'
-- group by asa.ShopCode ,asa.SellerSKU
-- )

-- ,t_tmp as (
-- SELECT 
-- 	case 
-- 		when site in ("UK","DE","FR","ES","IT","US","CA","MX") then 7 - `开窗_各站点mark1_2已标注数`  
-- 		when site in ("AU","SE","NL","PL","JP") then 5 - `开窗_各站点mark1_2已标注数` 
-- 	end as `各站点应补充保留数` 
-- 	,ROW_NUMBER() over(partition by NodePathName ,sku order by `近8周访客数` desc ) `近8周访客数降序` 
-- 	,ROW_NUMBER() over(partition by NodePathName ,sku order by `近60天广告点击量` desc ) `近60天广告点击量降序` 
-- 	,ROW_NUMBER() over(partition by NodePathName ,sku order by `近60天广告曝光量` desc ) `近60天广告曝光量降序` 
-- 	, ta.*
-- from (
-- 	select 
-- 		count(COALESCE(mark1,mark2)) over(partition by nodepathname , sku ,site ) `开窗_各站点mark1_2已标注数` 
-- 		,res_list_2.*
-- 		,`近60天广告点击量`
-- 		,`近60天广告曝光量`
-- 	from res_list_2 
-- 	left join t_ad_stat on res_list_2.ShopCode = t_ad_stat.ShopCode and res_list_2.SellerSKU = t_ad_stat.SellerSKU  
-- 	) ta  
-- )
-- 
-- ,res_list_3 as (
-- select 
-- 	case when 各站点应补充保留数 > 0 and `近8周访客数降序`<各站点应补充保留数 and COALESCE(mark1,mark2) is null 
-- 		then '保留_近8周访客' end as mark3
-- 	,t_tmp.*
-- from t_tmp
-- )



-- 查看截至目前，每个团队，每个账号已保留数 
-- select 
-- 	 NodePathName ,AccountCode
-- 	,count(COALESCE(mark1,mark2))  `mark1_2已标注uk链接数` 
-- from res_list_2
-- group by NodePathName ,AccountCode 


-- select BoxSKU  
-- 	,count(distinct concat(shopcode,SellerSku) ) `在线链接数` 
-- 	,count(distinct case when NodePathName ='快次元-成都销售组' then concat(shopcode,SellerSku) end ) `在线链接数_成1` 
-- 	,count(distinct case when NodePathName ='快次方-成都销售组' then concat(shopcode,SellerSku) end ) `在线链接数_成2` 
-- 	,count(distinct case when NodePathName ='运营组-泉州1组' then concat(shopcode,SellerSku) end ) `在线链接数_泉1` 
-- 	,count(distinct case when NodePathName ='运营组-泉州2组' then concat(shopcode,SellerSku) end ) `在线链接数_泉2` 
-- 	,count(distinct case when NodePathName ='运营组-泉州3组' then concat(shopcode,SellerSku) end ) `在线链接数_泉3` 
-- from res_list_2
-- where length(COALESCE(mark1,mark2)) >0
-- group by BoxSKU  
-- order by `在线链接数`  desc 


-- ,t_site_sort_pre as (
-- select ['UK-1','DE-2','FR-3','ES-4','IT-5','US-6','CA-7','MX-8','AU-9','SE-10','NL-11','PL-12','JP-13'] arr 
-- )
-- 
-- ,t_site_sort as (
-- select split(arr,'-')[1] site ,split(arr,'-')[2] sort
-- from (select unnest as arr 
-- 	from t_site_sort_pre ,unnest(arr)
-- 	) tmp 
-- )




-- , t_list_stat as (
-- select BoxSKU  
-- 	,count(distinct concat(t_list.shopcode,t_list.SellerSku) ) `快百货在线链接数` 
-- 	,count(distinct case when NodePathName ='快次元-成都销售组' then concat(t_list.shopcode,t_list.SellerSku) end ) `在线链接数_成1` 
-- 	,count(distinct case when NodePathName ='快次元-泉州销售组' then concat(t_list.shopcode,t_list.SellerSku) end ) `在线链接数_泉1` 
-- 	,count(distinct case when NodePathName ='快次方-成都销售组' then concat(t_list.shopcode,t_list.SellerSku) end ) `在线链接数_成2` 
-- 	,count(distinct case when NodePathName ='快次方-泉州销售组' then concat(t_list.shopcode,t_list.SellerSku) end ) `在线链接数_泉2`
-- 	
-- 	,count(distinct case when NodePathName ='快次元-成都销售组' and site='UK' then concat(t_list.shopcode,t_list.SellerSku) end ) `在线链接数_成1_UK` 
-- 	,count(distinct case when NodePathName ='快次元-泉州销售组' and site='UK' then concat(t_list.shopcode,t_list.SellerSku) end ) `在线链接数_泉1_UK` 
-- 	,count(distinct case when NodePathName ='快次方-成都销售组' and site='UK' then concat(t_list.shopcode,t_list.SellerSku) end ) `在线链接数_成2_UK` 
-- 	,count(distinct case when NodePathName ='快次方-泉州销售组' and site='UK' then concat(t_list.shopcode,t_list.SellerSku) end ) `在线链接数_泉2_UK` 
-- from t_list
-- group by BoxSKU  
-- )


-- 
-- ,t_od_stat as (
-- select shopcode , SellerSKU ,count(distinct PlatOrderNumber ) `22-23年订单数`
-- from t_orde where OrderStatus != '作废' and TotalGross > 0 
-- group by shopcode , SellerSKU
-- )
-- 
-- ,t_sale_stat as (
-- select BoxSKU   
-- 	,count(distinct concat(shopcode,sellersku) ) `出单链接数` 
-- 	,count(distinct case when NodePathName ='快次元-成都销售组' then  concat(shopcode,sellersku) end ) `出单链接数_成1` 
-- 	,count(distinct case when NodePathName ='快次元-泉州销售组' then  concat(shopcode,sellersku) end ) `出单链接数_泉1` 
-- 	,count(distinct case when NodePathName ='快次方-成都销售组' then  concat(shopcode,sellersku) end ) `出单链接数_成2` 
-- 	,count(distinct case when NodePathName ='快次方-泉州销售组' then  concat(shopcode,sellersku) end ) `出单链接数_泉2` 
-- from t_orde
-- group by BoxSKU  
-- )

-- 表1 明细
-- select t_list_stat.* ,t_sale_stat.*
-- -- select count(1)
-- from t_list_stat  
-- left join t_sale_stat on t_sale_stat.boxsku =t_list_stat.boxsku 

-- 表2 统计
-- select 
-- 	count( case when 在线链接数_成1 > 70 then boxsku end) `快次元成都-超标SKU数` 
-- 	,sum( case when 在线链接数_成1 > 70 then  在线链接数_成1 - 70 end ) `快次元成都-超标链接数` 
-- 	,count( case when 在线链接数_成2 > 70 then boxsku end) `快次方成都-超标SKU数` 
-- 	,sum( case when 在线链接数_成2 > 70 then  在线链接数_成2 - 70 end ) `快次方成都-超标链接数` 
-- 	,count( case when 在线链接数_泉1 > 70 then boxsku end) `快次元泉州-超标SKU数` 
-- 	,sum( case when 在线链接数_泉1 > 70 then  在线链接数_泉1 - 70 end ) `快次元泉州-超标链接数` 
-- 	,count( case when 在线链接数_泉2 > 70 then boxsku end) `快次方泉州-超标SKU数` 
-- 	,sum( case when 在线链接数_泉2 > 70 then  在线链接数_泉2 - 70 end ) `快次方泉州-超标链接数` 
-- from t_list_stat  

-- 表3 每个组一个SKU
-- select '快次元-成都销售组' `团队` ,t_list.* ,`22-23年订单数`  ,`近60天广告点击量` ,`近60天广告曝光量`
-- from t_list
-- left join t_ad_stat on t_list.ShopCode = t_ad_stat.ShopCode and t_list.SellerSKU = t_ad_stat.SellerSKU  
-- left join t_od_stat on t_list.ShopCode = t_od_stat.ShopCode and t_list.SellerSKU = t_od_stat.SellerSKU  
-- where boxsku = 3539201 and NodePathName ='快次元-成都销售组'
-- union all 
-- select '快次方-成都销售组' `团队` ,t_list.* ,`22-23年订单数` ,`近60天广告点击量` ,`近60天广告曝光量`
-- from t_list
-- left join t_ad_stat on t_list.ShopCode = t_ad_stat.ShopCode and t_list.SellerSKU = t_ad_stat.SellerSKU  
-- left join t_od_stat on t_list.ShopCode = t_od_stat.ShopCode and t_list.SellerSKU = t_od_stat.SellerSKU  
-- where boxsku = 3717359 and NodePathName ='快次方-成都销售组'
-- union all 
-- select '快次元-泉州销售组' `团队` ,t_list.* ,`22-23年订单数`  ,`近60天广告点击量` ,`近60天广告曝光量`
-- from t_list
-- left join t_ad_stat on t_list.ShopCode = t_ad_stat.ShopCode and t_list.SellerSKU = t_ad_stat.SellerSKU  
-- left join t_od_stat on t_list.ShopCode = t_od_stat.ShopCode and t_list.SellerSKU = t_od_stat.SellerSKU  
-- where boxsku = 3529944 and NodePathName ='快次元-泉州销售组'
-- union all 
-- select '快次方-泉州销售组' `团队` ,t_list.* ,`22-23年订单数`  ,`近60天广告点击量` ,`近60天广告曝光量`
-- from t_list
-- left join t_ad_stat on t_list.ShopCode = t_ad_stat.ShopCode and t_list.SellerSKU = t_ad_stat.SellerSKU  
-- left join t_od_stat on t_list.ShopCode = t_od_stat.ShopCode and t_list.SellerSKU = t_od_stat.SellerSKU  
-- where boxsku = 4297256 and NodePathName ='快次方-泉州销售组'
