-- 结论 缺少陈的订单数据是因为对应SKU的链接在当月刊登当月删除，而原需求的逻辑口径没有计算当月删除链接的记录

-- 聚合到出单产品SKU
with
t_orde as (  -- 每周出单明细
select dd.week_num_in_year pay_week
    ,dd.week_begin_date as pay_week_begin_date
    ,OrderNumber ,PlatOrderNumber ,TotalGross,TotalProfit,TotalExpend ,SaleCount
	,ExchangeUSD,TransactionType,SellerSku,RefundAmount,AdvertisingCosts,Asin,BoxSku ,Product_SPU as spu
    ,PurchaseCosts
	,paytime
	,ms.department ,ms.split_part(NodePathNameFull,'>',2) dep2 ,ms.NodePathName  ,ms.SellUserName ,ms.Code as shopcode
from import_data.wt_orderdetails wo
left join dim_date dd on date ( paytime ) = dd.full_date
join import_data.mysql_store ms on wo.shopcode=ms.Code
	and paytime >= '${StartDay}' and paytime <'${NextStartDay}'
	and ms.Department = '快百货'
	and wo.IsDeleted=0
    and OrderStatus != '作废'
-- where BoxSku = 4957826
)

,t_list as ( -- 23年内刊登链接
select a.*
    ,dd.week_num_in_year pub_week
    ,dd.week_begin_date as pub_week_begin_date
from (
select wl.BoxSku ,wl.SKU ,MinPublicationDate ,IsDeleted  ,wl.ShopCode ,SellerSKU ,wl.ASIN
    ,MONTH( MinPublicationDate) pub_month
	,year( MinPublicationDate) pub_year
	,ms.department ,split_part(NodePathNameFull,'>',2) dep2 ,ms.NodePathName
	,case when ms.SellUserName is null then '店铺无首选销售员' else ms.SellUserName end as SellUserName
from wt_listing wl
join import_data.mysql_store ms on wl.ShopCode = ms.Code
where
	MinPublicationDate>= '${StartDay}' and MinPublicationDate <'${NextStartDay}'
	-- and wl.IsDeleted = 0
	and ms.Department = '快百货'
	and SellerSku not regexp '-BJ-|-BJ|BJ-|bJ|Bj|bj|BJ'
    and BoxSku = 4957826
) a
left join dim_date dd on date(a.MinPublicationDate) = dd.full_date
)

,t_elem as ( -- 元素映射表，最小粒度是 SKU+NAME
select eppaea.sku ,epp.boxsku ,GROUP_CONCAT( eppea.Name ) ele_name
from import_data.erp_product_product_associated_element_attributes eppaea
left join import_data.erp_product_product_element_attributes eppea on eppaea.ElementAttributeId = eppea.Id
join erp_product_products epp  on eppaea.sku = epp.sku and epp.IsDeleted = 0 and epp.IsMatrix = 0
group by eppaea.sku ,epp.boxsku
)

,t_sale_sku as (  -- 每周出单SKU
select o.dep2 ,o.NodePathName ,o.BoxSku , o.spu
	,sum(salecount) `出单SKU件数`
	,round( sum((TotalGross)/ExchangeUSD),2)  `销售额`
	,round( sum((TotalProfit)/ExchangeUSD),2)  `利润额`
	,count(distinct PlatOrderNumber)  `订单数`
	,count(distinct concat(o.shopcode,o.sellersku))  `出单链接数`
	,count(distinct o.boxsku)  `出单sku数`
from t_orde o join t_list l on l.shopcode = o.shopcode and l.sellersku = o.sellersku and l.asin = o.asin
group by o.dep2 ,o.NodePathName ,o.BoxSku, o.spu
)

,prod_seller as (
select spu ,group_concat(SellUserName) seller_list
from (
    select spu, eaapis.SellUserName
    from erp_amazon_amazon_product_in_sells eaapis
    join wt_products wp on eaapis.ProductId = wp.id and wp.ProjectTeam='快百货' and wp.IsDeleted = 0
    group by spu, eaapis.SellUserName
    ) tmp
group by spu
)

,res as (
select
	replace(concat(right(date('${StartDay}'),5),'至',right(date(date_add('${NextStartDay}',-1)),5)),'-','') `刊登时间范围`
	,replace(concat(right(date('${StartDay}'),5),'至',right(date(date_add('${NextStartDay}',-1)),5)),'-','') `付款时间范围`
	,t_sale_sku.dep2 `团队`
	,t_sale_sku.NodePathName  `小组`
	,t_sale_sku.BoxSku
    ,t_sale_sku.spu
	,`出单SKU件数`
	,`销售额`
	,round(`销售额`/ `出单链接数`,1) `出单链接单产`
	,round(`销售额`/ `出单sku数`,1) `出单sku单产`
	,`利润额` ,`订单数`
	,wp.ProductName
	,wp.Cat1
	,wp.Cat2
	,wp.Cat3
	,wp.Cat4
	,wp.Cat5
	,t_elem.ele_name `元素`
	,date(wp.DevelopLastAuditTime) `终审时间`
	,wp.DevelopUserName `开发人员`
    ,prod_seller.seller_list `SPU对应销售人员`
from t_sale_sku
left join import_data.wt_products wp on t_sale_sku.boxsku = wp.BoxSku
left join t_elem on t_sale_sku.boxsku =t_elem.boxsku
left join prod_seller on t_sale_sku.spu =prod_seller.spu
order by `团队` , `小组`
)

select * from res
-- select sum(销售额) from res

select a.* ,b.MinPublicationDate
from ( select BoxSku ,asin ,site  from import_data.wt_orderdetails where boxsku = '4957826' and PayTime >= '2023-09-01' ) a
left join ( select asin ,MarketType as site ,MinPublicationDate
            from wt_listing  wl join import_data.mysql_store ms on wl.ShopCode = ms.Code and ms.department = '快百货'
            and SellerSku not regexp '-BJ-|-BJ|BJ-|bJ|Bj|bj|BJ'
            group by asin ,MarketType ,MinPublicationDate ) b
on a.asin = b.asin and a.site = b.site