-- todo 聚合表输出需要先写入临时表，再查询导出（因为一次要多周） ； 链接明细可以直接查SQL导出（因为只有一周）

insert into manual_table_duplicate (wttime,c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,c11,c12,c13,c14,c15,c16,c17,c18,c19,c20,c21,c22,c23,c24,c25,c26,c27,c28,c29,c30,c31,c32,c33,c34,c35,c36)
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
from wt_products wp
left join dep_kbh_product_test vke on wp.SKU = vke.sku
where wp.ProjectTeam='快百货' and wp.IsDeleted=0
  -- and wp.ProductStatus !=2
)

,mysql_store_team as ( -- 剔除定制运营组,增加dep2区域维度
select case when NodePathName regexp  '成都' then '成都' else '泉州' end as dep2,* from import_data.mysql_store where Department = '快百货' and NodePathName != '定制运营组'
)

,od_pay as (   -- 销售额不含退款数据，利润额不含退款不含广告
select wo.shopcode ,wo.SellerSku ,ifnull(wo.Product_Sku,0) as sku
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
    ,abs( round( sum(  (LocalFreight + OverseasDeliveryFee + HeadFreight + FBAFee ) /ExchangeUSD ) ,4) ) 物流成本
    ,sum( case when FeeGross = 0 and OrderStatus <> '作废' and TransactionType = '付款' then TotalGross/ExchangeUSD end ) ori_gross
    ,sum( case when FeeGross = 0 and OrderStatus <> '作废' and TransactionType = '付款' then TotalProfit/ExchangeUSD end ) ori_profit
from import_data.wt_orderdetails wo
join mysql_store_team  ms on wo.shopcode=ms.Code
left join view_kbh_add_refunddate_to_wtord_tmp vr on wo.OrderNumber = vr.OrderNumber
left join dep_kbh_product_test d on wo.BoxSku = d.boxsku
left join view_kbh_lst_pub_tag vl on wo.shopcode =vl.shopcode and wo.sellersku = vl.sellersku and wo.BoxSku=vl.boxsku  -- vl整个视图只有37条boxsku为空，目前比较靠谱的匹配方案
left join wt_products wp on wo.Product_Sku =wp.sku and wp.IsDeleted=0 and wp.ProjectTeam='快百货'
where wo.IsDeleted = 0 and PayTime >='${StartDay}' and PayTime<'${NextStartDay}'
group by wo.shopcode ,wo.SellerSku ,wo.Product_Sku
)

,od_refund as ( -- 销售额对应退款额，利润额对应退款额
select shopcode ,SellerSku ,ifnull(wo.Product_Sku,0) as sku
    ,abs(round( sum( TotalGross/ExchangeUSD ),2 )) sales_refund
    ,abs(round( sum( TotalProfit/ExchangeUSD ),2 )) profit_refund
from import_data.wt_orderdetails wo
join ( select case when NodePathName regexp  '成都' then '快百货一部' else '快百货二部' end as dep2,* from import_data.mysql_store )  ms on wo.shopcode=ms.Code  and ms.Department='快百货'
join view_kbh_add_refunddate_to_wtord_tmp vr on wo.OrderNumber = vr.OrderNumber
where wo.IsDeleted = 0 and max_refunddate >='${StartDay}' and max_refunddate<'${NextStartDay}'  and TransactionType = '退款'
group by shopcode ,SellerSku ,sku
)

,od_stat_pre as ( -- 扣退款
select  shopcode  ,sellersku ,sku
    ,sum( sales_undeduct_refunds ) as sales
    ,sum( profit_undeduct_refunds ) as profit
    ,sum( sales_refund ) as sales_refund
from (
    select  shopcode  ,sellersku  ,sku , sales_undeduct_refunds  ,profit_undeduct_refunds ,0 as  sales_refund from od_pay a
    union
    select  shopcode  ,sellersku ,sku , -1*sales_refund  ,-1*profit_refund ,sales_refund  from od_refund a
    ) t
group by shopcode  ,sellersku ,sku
)

,od_stat as(
select a.shopcode ,a.SellerSku ,a.sku ,sales ,profit ,sales_refund
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

,t_ad as ( --
select  waad.shopcode ,waad.SellerSku ,waad.sku
     ,AdSales as TotalSale7Day , AdSaleUnits as TotalSale7DayUnit
    , waad.AdClicks as Clicks  , waad.AdExposure as Exposure ,waad.AdSpend as Spend
    , AdROAS as ROAS ,AdAcost as ACOS
from wt_adserving_amazon_daily waad -- 保留所有打标签链接，并对有曝光数据的链接进行行拆分
join  mysql_store ms on ms.code = waad.ShopCode and ms.Department = '快百货' and  GenerateDate >=  date_add('${StartDay}',interval -1 day) and GenerateDate <  date_add('${NextStartDay}',interval -1 day)
left join dep_kbh_lst_sku_maps_test wl on waad.ShopCode = wl.ShopCode and  waad.SellerSKU = wl.SellerSKU -- todo 广告表sku出问题时 临时重新生成数据使用
)

,add_ad_sku as ( -- todo 临时补充sku, 需解决广告日表中缺失SKU问题》进而需要解决erp_listing表中 ProductId 无效的问题
select  wl.SellerSKU ,wl.ShopCode ,max(wl.sku) sku
from (select shopcode ,sellersku from t_ad where sku is null group by shopcode, sellersku) t1
join erp_amazon_amazon_listing wl on wl.ShopCode = t1.ShopCode and wl.SellerSKU = t1.SellerSku
group by wl.SellerSKU ,wl.ShopCode
)

, t_ad_stat as (
select  t1.shopcode  ,t1.SellerSku  ,coalesce(t1.sku,t2.sku) sku
-- 曝光量
, round(sum(Exposure)) as ad_sku_Exposure
-- 广告花费
, round(sum(Spend),2) as ad_Spend
-- 广告销售额
, round(sum(TotalSale7Day),2) as ad_TotalSale7Day
-- 广告销量
, round(sum(TotalSale7DayUnit),2) as ad_sku_TotalSale7DayUnit
-- 点击量
, round(sum(Clicks)) as ad_sku_Clicks
from t_ad  t1
left join add_ad_sku t2  on t2.ShopCode = t1.ShopCode and t2.SellerSKU = t1.SellerSku
group by  t1.shopcode  ,t1.SellerSku  ,coalesce(t1.sku,t2.sku)
)

,t_online_lst as (
select ShopCode ,SellerSKU ,sku
from wt_listing wl join mysql_store ms on wl.ShopCode=ms.Code and ms.Department='快百货' and ListingStatus = 1 and ShopStatus='正常' group by ShopCode, SellerSKU, sku
)

,ware_stat as(
select   round( sum( `当前在仓产品金额`)/10000,4) `总在仓产品金额_万元` -- 万元
from  dep_kbh_product_test wp
join  (
	SELECT boxsku ,sum(ifnull(TotalPrice,0)) `当前在仓产品金额`
	FROM ( -- local_warehouse 本地仓表
		select TotalPrice, TotalInventory ,wi.boxsku
		FROM import_data.daily_WarehouseInventory wi
		join ( select BoxSku ,projectteam as department from wt_products where  IsDeleted=0 and ProjectTeam='快百货' ) tmp on wi.BoxSku = tmp.BoxSku
		where WarehouseName = '东莞仓' and TotalInventory > 0
		  and CreatedTime = date_add('${NextStartDay}',-1) and department = '快百货'
		)  tmp
	group by boxsku
) ware on wp.boxsku = ware.boxsku
)

,prod_stat as ( -- 不看链接分层和出单团队
select  count(distinct a.spu) 总未停产SPU数
from dep_kbh_product_test a
left join wt_products wp on a.sku = wp.sku and IsDeleted=0 and ProjectTeam='快百货'
where a.ProductStatus !=2
)

,online_lst as (
select shopcode , sellersku from erp_amazon_amazon_listing eaal join mysql_store_team ms on eaal.ShopCode = ms.code
    and ShopStatus='正常' and ListingStatus=1 group by shopcode ,sellersku
)

,t0 as ( -- todo 广告表中有该链接，但链接表中无该链接，导致链接关联SKU未成功  ShopCode='ZI-ES'  and SellerSKU = 'P230920F8VY02TZIUK-02'
select t.* ,prod.spu
     ,week_num_in_year ,month, '${StartDay}' firstday
     ,终审年月 ,新老品 ,主题, 高潜 ,一级类目 ,优先级元素
     ,case when SellerSku regexp 'Event' then '是' else '否' end 是否结算项记录
from ( select shopcode ,SellerSku , sku from od_stat
    union select shopcode ,SellerSku , sku from t_online_lst
    union select shopcode ,SellerSku , sku from t_ad_stat  -- where length(sku) >0 -- 广告表里面存在sku为空的记录
    ) t
join ( select week_num_in_year,month from dim_date where full_date = '${StartDay}' ) dd
left join prod on t.sku =prod.sku
)

,res1 as (
select now() ,'${StartDay}' as firstday , '${ReportType}' as reporttype
    ,ms.ShopStatus ,t0.shopcode ,t0.SellerSKU
    ,t0.sku ,t0.spu
    ,新老品  ,主题 ,t0.优先级元素  ,高潜 ,一级类目 ,终审年月
    ,ifnull(lst_pub_tag ,'其他链接')  链接刊登划分
    ,case when '${ReportType}' = '周报' then week_num_in_year when '${ReportType}' = '月报' then month end as 自然周月
     ,firstday as 当期第一天 ,ms.CompanyCode ,ms.AccountCode ,区域 ,销售小组 ,销售人员
    ,ifnull(salecount,0) `销量`
    ,ifnull(orders_cnt,0) `订单量`
    ,ifnull(sales,0) `销售额`
    ,ifnull(profit,0) 利润额_未扣ad
    ,round(ifnull(profit,0) - ifnull(ad_Spend,0),2) `利润额_扣ad`
    ,ifnull(ori_gross,0) `销售额_扣运费未扣退款`
    ,ifnull(ori_profit,0) `利润额_扣运费未扣退款`
    ,round (  ori_profit /  ori_gross  ,4 ) 挂单利润率
    ,ifnull(sales_refund,0) `退款额`
    ,ifnull(运费收入,0) `运费收入`
    ,ifnull(交易成本,0) `交易成本`
    ,ifnull(采购成本,0) `采购成本`
    ,ifnull(物流成本,0) `物流成本`
    ,ad_sku_Exposure `广告曝光量`
    ,ifnull(ad_Spend,0) `广告花费`
    ,ad_TotalSale7Day `广告销售额`
    ,ad_sku_TotalSale7DayUnit `广告销量`
    ,ad_sku_Clicks `广告点击量`
    ,是否结算项记录
    ,ol.SellerSKU as online_sellersku
from t0
left join od_stat on t0.ShopCode = od_stat.ShopCode and t0.SellerSku = od_stat.SellerSku and t0.sku =od_stat.sku
left join t_ad_stat  on t0.ShopCode = t_ad_stat.ShopCode and t0.SellerSku = t_ad_stat.SellerSku
left join view_kbh_lst_pub_tag vl on t0.SellerSku=vl.SellerSKU and t0.shopcode = vl.shopcode
left join (select * , case when NodePathName regexp  '成都' then '成都' else '泉州' end as 区域 , NodePathName as 销售小组 ,SellUserName 销售人员
      from mysql_store where Department = '快百货') ms on t0.shopcode = ms.code
join erp_product_products epp on epp.sku = t0.sku and epp.ProjectTeam='快百货' and epp.IsMatrix=0
left join online_lst ol on t0.ShopCode = ol.ShopCode and t0.SellerSku = ol.SellerSku
order by t0.shopcode ,t0.SellerSKU ,t0.sku ,自然周月 ,当期第一天
)


,res2 as ( -- 链接聚合
select now() ,'${StartDay}' as firstday , '${ReportType}' as reporttype
    ,ShopStatus ,res1.shopcode ,链接刊登划分 ,终审年月 ,新老品 ,优先级元素 ,自然周月 ,当期第一天  ,CompanyCode,AccountCode,区域,销售小组,销售人员
    ,round(sum(销量),0) 销量
    ,round(sum(销售额),2) 销售额
    ,round(sum(利润额_扣ad),2) 利润额_扣ad
    ,round(sum(利润额_未扣ad),2) 利润额_未扣ad
    ,round(sum(销售额_扣运费未扣退款),2) 销售额_扣运费未扣退款
    ,round(sum(利润额_扣运费未扣退款),2) 利润额_扣运费未扣退款
    ,round(sum(退款额),2) 退款额
    ,round(sum(广告曝光量)) 广告曝光量
    ,round(sum(广告花费),2)  广告花费
    ,round(sum(广告销售额),2) 广告销售额
    ,round(sum(广告销量),2) 广告销量
    ,round(sum(广告点击量),2) 广告点击量
    ,round(sum(运费收入),2) 运费收入
    ,round(sum(交易成本),2) 交易成本
    ,round(sum(采购成本),2) 采购成本
    ,round(sum(物流成本),2) 物流成本
    ,主题 ,高潜 ,一级类目 ,是否结算项记录
    ,count( distinct online_sellersku) 在线渠道SKU数
from res1
group by ShopStatus ,res1.shopcode ,新老品  ,主题 ,优先级元素 ,高潜,一级类目 ,终审年月 ,链接刊登划分 ,自然周月 ,当期第一天,CompanyCode,AccountCode,区域,销售小组,销售人员 ,是否结算项记录
)


-- 明细表
-- select * from res1 ;
-- 聚合表
select * from res2
-- select count(1) from res2;



-- 广告对比
-- select sum(ad_Spend) from t_ad_stat;
-- select sum(退款额) from res1;

-- 销售对比
-- select sum(利润额_扣ad)/sum(销售额) from res3;
-- select sum(当前未停产SPU数) from res3;
-- select sum(TotalGross_weekly) from t_orde_week_stat;

