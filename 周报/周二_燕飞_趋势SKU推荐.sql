
/*
-- 每周二 （周二才能拿到完整一周广告数据）
UK,DE 2个站点单站点的订单量达到以下标准的SKU：
1，近7天4天以上出单
2，近7天累计5单且环比前7天单量达1.5倍
3，近14天客单价8块以上

字段要体现：SPU，SKU，赛盒SKU，站点（就是SKU是从哪个站点的订单量来的）
，销量，销售额，利润，泉州刊登套数
，泉州刊登账号（账号体现到比如PQ-EU或者美洲这样即可）
，泉州刊登销售人员，元素标签、终审时间，提取周别
*/

-- NextStartDay 取周一，以便近7和前7对应自然周

with
t_prod as ( -- 新品:7月后终审
select SKU ,SPU ,DATE_ADD(DevelopLastAuditTime,interval - 8 hour) as DevelopLastAuditTime
from import_data.erp_product_products 
where DATE_ADD(DevelopLastAuditTime,interval - 8 hour)  >= '2023-03-01' 
and IsMatrix = 0 and IsDeleted = 0 
and ProjectTeam ='快百货' and Status = 10
)
-- select * from epp  '`DevelopLastAuditTime`' 

,t_orde as (
select OrderNumber ,PlatOrderNumber ,TotalGross,TotalProfit,TotalExpend ,shopcode ,asin
	,ExchangeUSD,TransactionType,SellerSku,RefundAmount,SalesGross ,salecount
	,wo.Product_SPU as SPU
	,wo.Product_Sku  as SKU
    ,case when date_add(Product_DevelopLastAuditTime , interval - 8 hour) >=  '2023-07-01'
        then '新品' else '老品' end as isnewpp
	,PayTime
	,ms.department ,split_part(ms.NodePathNameFull,'>',2) dep2 ,ms.NodePathName ,ms.site
	,case when (TotalGross - FeeGross)/ExchangeUSD >= 8 then 1 else 0 end as isOver8usd
from import_data.wt_orderdetails wo
join import_data.mysql_store ms on wo.shopcode=ms.Code
where
	PayTime >=date_add(  subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1) , INTERVAL -14 DAY) and PayTime <  subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1) 
	and wo.IsDeleted=0
	and ms.Department = '快百货'  and TransactionType = '付款' -- 未含付款类型为其他
     and ms.nodepathname regexp '泉州'
)

-- ---------- 产品打标签
,t_orde_stat as ( -- 产品打标签的特征数据
select SKU ,site
	,count( distinct case when timestampdiff(SECOND,paytime,subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1))/86400  <= 14 then PlatOrderNumber end) orders_in14d
    ,count( distinct case when  PayTime >=date_add(subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1) ,interval -7 day) and PayTime < date_add(subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1) ,interval -0 day) then date(PayTime) end ) as order_days_in1_7
    ,count( distinct case when  PayTime >=date_add(subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1) ,interval -7 day) and PayTime < date_add(subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1) ,interval -0 day) then PlatOrderNumber end ) as orders_in1_7
	,count( distinct case when  PayTime >=date_add(subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1) ,interval -14 day) and PayTime < date_add(subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1) ,interval -7 day) then PlatOrderNumber end ) as orders_in8_14
	,count( distinct case when isOver8usd = 1 then PlatOrderNumber end ) orders_over_8usd -- 除运费超8美金订单数
from t_orde
where site regexp 'DE|UK'
group by SKU ,site
)
-- select * from t_orde_stat

,pre_prod_mark as (
select SKU ,site  ,'近7天达4天出单且客单达8' prod_type
from t_orde_stat where  order_days_in1_7 >= 4 and  orders_over_8usd >= 0
union
select SKU ,site  ,'近7天累计5单且较前7天达1.5倍且客单达8' prod_type
from t_orde_stat where  orders_in1_7 >= 5 and orders_in1_7 / orders_in8_14 >=1.5 and  orders_over_8usd >= 0
)

,prod_mark as (
select a.sku  ,prod_type ,type_source_site
from (select distinct sku from  pre_prod_mark ) a
left join (
	select SKU ,GROUP_CONCAT(prod_type) prod_type
	from (select distinct  SKU ,prod_type from pre_prod_mark) tmp group by SKU ) b on a.sku = b.sku
left join (
	select SKU ,GROUP_CONCAT(source) type_source_site
	from (select distinct  SKU ,concat(site ,prod_type) as source  from pre_prod_mark) tmp group by SKU ) c on a.sku = c.sku
)
-- select * from prod_mark

-- ----------计算订单表现
,t_orde_week_stat as ( -- 用于累计订单 （不区分站点）
select SKU
    ,count( distinct case when  PayTime >=date_add(subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1) ,interval -7 day) and PayTime < date_add(subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1) ,interval -0 day) then PlatOrderNumber end ) as total_orders_in1_7
	,count( distinct case when  PayTime >=date_add(subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1) ,interval -14 day) and PayTime < date_add(subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1) ,interval -7 day) then PlatOrderNumber end ) as total_orders_in8_14

    ,sum(  case when  PayTime >=date_add(subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1) ,interval -7 day) and PayTime < date_add(subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1) ,interval -0 day) then salecount end ) as total_salecount_in1_7
	,sum(  case when  PayTime >=date_add(subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1) ,interval -14 day) and PayTime < date_add(subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1) ,interval -7 day) then salecount end ) as total_salecount_in8_14

    ,round(sum( case when PayTime >=date_add(subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1) ,interval -7 day) and PayTime < date_add(subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1) ,interval -0 day) then TotalGross/ExchangeUSD end ),2) as TotalGross_in1_7
	,round(sum( case when PayTime >=date_add(subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1) ,interval -14 day) and PayTime < date_add(subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1) ,interval -7 day) then TotalGross/ExchangeUSD end ),2) as TotalGross_in8_14

    ,round(sum( case when PayTime >=date_add(subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1) ,interval -7 day) and PayTime < date_add(subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1) ,interval -0 day) then TotalProfit/ExchangeUSD end ),2) as TotalProfit_in1_7
	,round(sum( case when PayTime >=date_add(subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1) ,interval -14 day) and PayTime < date_add(subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1) ,interval -7 day) then TotalProfit/ExchangeUSD end ),2) as TotalProfit_in8_14
from t_orde
where PayTime >=date_add(subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1), INTERVAL -14 DAY) and PayTime < subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1)
group by SKU
)
-- select * from t_orde_week_stat


,t_list as (
select eaal.SPU ,eaal.SKU ,BoxSku  ,MarketType ,SellerSKU ,ShopCode ,asin
	,DevelopUserName ,ProductStatus
	,ms.Site ,ms.SellUserName  ,ms.NodePathName ,ms.CompanyCode ,ms.Accountcode
from import_data.erp_amazon_amazon_listing eaal
join prod_mark on eaal.sku = prod_mark.sku
join import_data.mysql_store ms on eaal.ShopCode = ms.Code and ms.shopstatus = '正常' and eaal.listingstatus = 1
    and ms.Department = '快百货' and ms.nodepathname regexp '泉州' and eaal.IsDeleted = 0
)

,t_list_stat as (
select a.sku ,online_Co_cnt ,online_shop_name_concated ,online_seller_concated
from (select sku ,count( distinct CompanyCode ) online_Co_cnt from t_list group by sku ) a
left join ( select sku ,group_concat(Accountcode ) online_shop_name_concated  from ( select distinct sku ,Accountcode from t_list ) t group by sku ) b on a.sku = b.sku
left join ( select sku ,group_concat(SellUserName ) online_seller_concated  from ( select distinct sku ,SellUserName from t_list ) t group by sku ) c on a.sku = c.sku
)

, t_ad_stat as (
select sku
    ,sum( case when  CreatedTime >=date_add(subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1) ,interval -7 day) and CreatedTime < date_add(subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1) ,interval -0 day) then Spend end ) as ad_spend_in1_7
    ,sum( case when  CreatedTime >=date_add(subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1) ,interval -14 day) and CreatedTime < date_add(subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1) ,interval -7 day) then Spend end ) as ad_spend_in8_14
from (select distinct shopcode ,sellersku ,sku from t_orde ) ta
left join import_data.AdServing_Amazon asa on ta.ShopCode = asa.ShopCode and ta.SellerSKU = asa.SellerSKU
group by sku
)
-- select * from t_ad_stat

,t_merage as (
select
	prod_mark.prod_type `趋势SKU标签`
    ,prod_mark.type_source_site `标签来源站点`
    ,prod_mark.sku
    ,wp.spu
    ,wp.boxsku
    ,date(subdate('${NextStartDay}',date_format('${NextStartDay}','%w')-1)) `数据统计日期`

    ,round( ifnull(TotalGross_in1_7,0) + ifnull(TotalGross_in8_14,0) ,2) `近14天总销售额`
    ,round( ( TotalProfit_in1_7 - ifnull(ad_spend_in1_7,0) + TotalProfit_in8_14 - ifnull(ad_spend_in8_14,0) ),2)  `14天总利润额`
    ,round( ( TotalProfit_in1_7 - ifnull(ad_spend_in1_7,0) + TotalProfit_in8_14 - ifnull(ad_spend_in8_14,0) ) / (ifnull(TotalGross_in1_7,0) + ifnull(TotalGross_in8_14,0) ) ,4 )  `近14天利润率`
    ,ifnull(total_orders_in1_7,0) + ifnull(total_orders_in8_14,0) `近14天总订单量`



    ,TotalGross_in1_7 `近7天总销售额`
    ,round(TotalProfit_in1_7 - ifnull(ad_spend_in1_7,0),2) `近7天总利润额`
    ,round( ( TotalProfit_in1_7 - ifnull(ad_spend_in1_7,0) )/ TotalGross_in1_7 ,4 )  `近7天利润率`
    ,total_orders_in1_7 `近7天总订单量`
    ,total_salecount_in1_7 `近7天总销量`

    ,TotalGross_in8_14 `前7天总销售额`
    ,round(TotalProfit_in8_14 - ifnull(ad_spend_in8_14,0),2) `前7天总利润额`
    ,round( (TotalProfit_in8_14 - ifnull(ad_spend_in8_14,0))/ TotalGross_in8_14 ,4 )  `前7天利润率`
    ,total_orders_in8_14 `前7天总订单量`
    ,total_salecount_in8_14 `前7天总销量`
     
    ,online_Co_cnt `泉州在线账号套数`
    ,online_shop_name_concated `泉州在线账号站点`
    ,online_seller_concated `首选业务员`
	,ProductName 
	,case when wp.ProductStatus = 0 then '正常'
		when wp.ProductStatus = 2 then '停产'
		when wp.ProductStatus = 3 then '停售'
		when wp.ProductStatus = 4 then '暂时缺货'
		when wp.ProductStatus = 5 then '清仓'
		end as  `产品状态`
	,ele_name `元素`
	,dkpl.prod_level `爆旺款`
	,DATE_ADD(DevelopLastAuditTime,interval - 8 hour)  `产品终审时间`
	,left(DevelopLastAuditTime,7) `产品终审月份`
	,DevelopUserName `开发人员`
from prod_mark
left join import_data.wt_products wp on prod_mark.sku =wp.sku and wp.IsDeleted = 0
left join t_list_stat on t_list_stat.sku = prod_mark.SKU
left join t_ad_stat on t_ad_stat.sku = prod_mark.SKU
left join t_orde_week_stat on  t_orde_week_stat.sku = prod_mark.SKU
left join ( -- 元素映射表，最小粒度是 SKU+NAME
	select eppaea.sku ,GROUP_CONCAT( eppea.Name ) ele_name
	from import_data.erp_product_product_associated_element_attributes eppaea
	left join import_data.erp_product_product_element_attributes eppea on eppaea.ElementAttributeId = eppea.Id
	group by eppaea.sku
	) t_elem on prod_mark.sku =t_elem .sku
left join ( select spu ,prod_level,FirstDay from dep_kbh_product_level where department = '快百货' and FirstDay = (select max(firstday) from dep_kbh_product_level) ) dkpl
	on wp.spu = dkpl.spu
)

-- select list_type ,count(DISTINCT shopcode  ,sellersku ) from t_ad_stat group by list_type   '`prod_key`.`ad_stat_week`' 
select * from t_merage