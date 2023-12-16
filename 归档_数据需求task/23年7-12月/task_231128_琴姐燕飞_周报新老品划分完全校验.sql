

with
prod as (
select wp.sku ,wp.spu ,wp.BoxSku
  ,ifnull(ele_name_priority,'无元素标签') 优先级元素
  ,ifnull(istheme,'非主题品') 主题
  ,ifnull(ispotenial,'非高潜品') 高潜
  ,left(DevelopLastAuditTime,7) 终审年月
    ,wp.cat1 一级类目
  ,case when wp.DevelopLastAuditTime >=  date_add( DATE_ADD('${StartDay}',interval -day( '${StartDay}'  )+1 day) ,interval -2 month)
    and wp.DevelopLastAuditTime <'${NextStartDay}' then '新品' else '老品' end as 新老品 -- 新老品快照
    ,ProductStatusName
from wt_products wp
join dep_kbh_product_test vke on wp.SKU = vke.sku
where wp.ProjectTeam='快百货' and wp.IsDeleted=0
)

,od_pay as (   -- 销售额不含退款数据，利润额不含退款不含广告
select wo.shopcode ,wo.SellerSku ,ifnull(wo.Product_Sku,0) as sku ,wo.BoxSku
    ,round( sum( case when TransactionType = '退款' then 0 else TotalGross/ExchangeUSD end ),2 ) sales_undeduct_refunds
    ,round( sum( case
	    	when TransactionType = '退款' then 0
	    	when TransactionType='其他' and left(wo.SellerSku,10)='ProductAds' then 0
	    	else TotalProfit/ExchangeUSD end ),2 ) profit_undeduct_refunds
    ,round( sum(salecount ),2) salecount
    ,count(distinct PlatOrderNumber) orders_cnt
    ,count(distinct Product_SPU) od_spu_cnt
	,round( sum(FeeGross/ExchangeUSD) ,4) `运费收入`
	,round( sum(TradeCommissions/ExchangeUSD) ,4) `交易成本`
	,round( sum(PurchaseCosts/ExchangeUSD) ,4) `采购成本`
    ,abs( round( sum(  (LocalFreight + OverseasDeliveryFee + HeadFreight + FBAFee ) /ExchangeUSD ) ,0 ) ) 物流成本
    ,sum( case when FeeGross = 0 and OrderStatus <> '作废' and TransactionType = '付款' then TotalGross/ExchangeUSD end ) ori_gross
    ,sum( case when FeeGross = 0 and OrderStatus <> '作废' and TransactionType = '付款' then TotalProfit/ExchangeUSD end ) ori_profit
from import_data.wt_orderdetails wo
join ( select case when NodePathName regexp  '成都' then '快百货一部' else '快百货二部' end as dep2,* from import_data.mysql_store )  ms on wo.shopcode=ms.Code  and ms.Department='快百货'
left join view_kbh_add_refunddate_to_wtord_tmp vr on wo.OrderNumber = vr.OrderNumber
left join dep_kbh_product_test d on wo.BoxSku = d.boxsku
left join view_kbh_lst_pub_tag vl on wo.shopcode =vl.shopcode and wo.sellersku = vl.sellersku and wo.BoxSku=vl.boxsku  -- vl整个视图只有37条boxsku为空，目前比较靠谱的匹配方案
left join wt_products wp on wo.Product_Sku =wp.sku and wp.IsDeleted=0 and wp.ProjectTeam='快百货'
where wo.IsDeleted = 0 and PayTime >='${StartDay}' and PayTime<'${NextStartDay}'
group by wo.shopcode ,wo.SellerSku ,wo.Product_Sku ,wo.BoxSku
)

,od_refund as ( -- 销售额对应退款额，利润额对应退款额
select shopcode ,SellerSku ,ifnull(wo.Product_Sku,0) as sku ,wo.BoxSku
    ,abs(round( sum( TotalGross/ExchangeUSD ),2 )) sales_refund
    ,abs(round( sum( TotalProfit/ExchangeUSD ),2 )) profit_refund
from import_data.wt_orderdetails wo
join ( select case when NodePathName regexp  '成都' then '快百货一部' else '快百货二部' end as dep2,* from import_data.mysql_store )  ms on wo.shopcode=ms.Code  and ms.Department='快百货'
join view_kbh_add_refunddate_to_wtord_tmp vr on wo.OrderNumber = vr.OrderNumber
where wo.IsDeleted = 0 and max_refunddate >='${StartDay}' and max_refunddate<'${NextStartDay}'  and TransactionType = '退款'
group by shopcode ,SellerSku ,sku ,wo.BoxSku
)

,od_stat_pre as ( -- 扣退款
select  shopcode  ,sellersku ,sku ,BoxSku
    ,sum( sales_undeduct_refunds ) as sales
    ,sum( profit_undeduct_refunds ) as profit
    ,sum( sales_refund ) as sales_refund
from (
    select  shopcode  ,sellersku  ,sku ,BoxSku , sales_undeduct_refunds  ,profit_undeduct_refunds ,0 as  sales_refund from od_pay a
    union
    select  shopcode  ,sellersku ,sku,BoxSku  , -1*sales_refund  ,-1*profit_refund ,sales_refund  from od_refund a
    ) t
group by shopcode  ,sellersku ,sku ,BoxSku
)

,od_stat as(
select a.shopcode ,a.SellerSku ,a.sku ,a.boxsku ,sales ,profit ,sales_refund
,salecount
, orders_cnt
,od_spu_cnt
, `运费收入`
,`交易成本`
,`采购成本`
,物流成本
,round(ori_gross,2) ori_gross
,round(ori_profit,2) ori_profit
from od_stat_pre a left join od_pay b on a.SellerSku =b.SellerSku and a.shopcode =b.shopcode and a.sku =b.sku
)

-- ----------计算广告表现


,t0 as ( -- todo 广告表中有该链接，但链接表中无该链接，导致链接关联SKU未成功  ShopCode='ZI-ES'  and SellerSKU = 'P230920F8VY02TZIUK-02'
select t.* ,prod.spu
     ,week_num_in_year ,month, '${StartDay}' firstday
     ,终审年月 ,新老品 ,主题, 高潜 ,一级类目 ,优先级元素
from ( select shopcode ,SellerSku , sku ,boxsku from od_stat
    ) t
join ( select week_num_in_year,month from dim_date where full_date = '${StartDay}' ) dd
left join prod on t.sku =prod.sku
)


-- 第一部分 有sku却未匹配到新老品:
-- 1.1 店铺属于快百货，出单产品属于特卖汇，因为匹配产品标签时需要用erp快百货产品库。解决：提交运营端业务去处理
select epp.sku as 当前sku ,* from (
    select * from (
        select distinct  wp.DevelopLastAuditTime 终审时间 ,wp.ProjectTeam 产品erp归属部门 , department 店铺归属部门 ,t.*
        from (select t0.shopcode,t0.SellerSku,t0.sku as 订单表sku, t0.boxsku ,新老品,department
            from t0
            left join od_stat on t0.ShopCode = od_stat.ShopCode and t0.SellerSku = od_stat.SellerSku and t0.sku =od_stat.sku
            join mysql_store ms on t0.shopcode =ms.code where 新老品 is null and t0.sku > 0  and t0.SellerSku not regexp 'Event' ) t
        left join wt_products wp on t.订单表sku =wp.sku and wp.IsDeleted=0 ) t2 where 产品erp归属部门 is not  null
    ) t3
    left join erp_product_products epp on t3.BoxSku = epp.BoxSKU and epp.IsDeleted=0 and epp.IsMatrix=0 and epp.ProjectTeam = '快百货';

-- 1.2 sku 与 boxsku的对照关系发生了变化, 订单表中当时记录的sku现在已匹配不到erp产品，按boxsku去匹配发现有新的sku。
-- 解决：按boxsku去匹配标签表 dep_kbh_product_test，即每次拿最新的匹配关系
select epp.sku as 当前sku ,* from (
    select * from (
        select distinct  wp.DevelopLastAuditTime 终审时间 ,wp.ProjectTeam 产品erp归属部门 , department 店铺归属部门 ,t.*
        from (select t0.shopcode,t0.SellerSku,t0.sku as 订单表sku, t0.boxsku ,新老品,department
            from t0
            left join od_stat on t0.ShopCode = od_stat.ShopCode and t0.SellerSku = od_stat.SellerSku and t0.sku =od_stat.sku
            join mysql_store ms on t0.shopcode =ms.code where 新老品 is null and t0.sku > 0  and t0.SellerSku not regexp 'Event' ) t
        left join wt_products wp on t.订单表sku =wp.sku and wp.IsDeleted=0 ) t2 where 产品erp归属部门 is null
    ) t3
    left join erp_product_products epp on t3.BoxSku = epp.BoxSKU and epp.IsDeleted=0 and epp.IsMatrix=0 and epp.ProjectTeam = '快百货';

-- 第二部分：定制运营组的部分出单产品，没有ERP系统sku ，所以未匹配到新老品等基于ERP的标签。
select NodePathName,shopcode ,SellerSku  ,wo.BoxSku 订单源塞盒SKU , Product_Sku ,wp.sku ,SaleCount 销量,OrderNumber ,PlatOrderNumber ,PayTime
from wt_orderdetails wo join mysql_store ms on ms.Code =wo.shopcode and ms.NodePathName='定制运营组' and Product_Sku is null and TransactionType='付款'and wo.IsDeleted = 0
left join wt_products wp on wo.BoxSku=wp.BoxSku
order by PayTime desc;



-- 解决第一部分
select eaal.sku 快百货在线sku,eaal.spu 在线spu ,case when wp.ProductStatus = 0 then '正常'
		when wp.ProductStatus = 2 then '停产'
		when wp.ProductStatus = 3 then '停售'
		when wp.ProductStatus = 4 then '暂时缺货'
		when wp.ProductStatus = 5 then '清仓'
		end as 产品状态 ,wp.ProjectTeam sku当前erp归属部门 ,eaal.ShopCode ,ms.CompanyCode ,ms.Department 店铺当前归属部门 ,ShopStatus 店铺当前状态
        ,wp.DevelopLastAuditTime
from erp_amazon_amazon_listing eaal
join mysql_store ms on eaal.ShopCode=ms.Code and ms.Department='快百货'
join erp_product_products wp on eaal.sku = wp.sku and ProjectTeam='特卖汇' and wp.IsDeleted=0 and wp.IsMatrix=0
where eaal.ListingStatus=1
order by ShopStatus desc