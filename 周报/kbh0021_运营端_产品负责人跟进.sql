with t0 as (  -- sku x 产品负责人
select distinct eaapis.SellUserName ,wp.spu  ,wp.sku
    ,wp.BoxSku ,ProductName 产品名称,wp.CategoryPathByChineseName 完整类目
    ,case when wp.ProductStatus = 0 then '正常'
		when wp.ProductStatus = 2 then '停产'
		when wp.ProductStatus = 3 then '停售'
		when wp.ProductStatus = 4 then '暂时缺货'
		when wp.ProductStatus = 5 then '清仓'
		end as 产品状态
    ,DevelopUserName 开发人员 ,date(DevelopLastAuditTime) 终审日期
    ,ele_name_group 元素 ,isnew 新老品 ,ele_name_priority 优先级元素
    ,left(wp.CreationTime,7) 产品添加年月
    ,case when  wp.CreationTime >= '2023-07-01' then '是' else '否' end 是否23年7月后添加
    ,dep2
from erp_amazon_amazon_product_in_sells eaapis
join wt_products wp on eaapis.ProductId = wp.id and wp.ProjectTeam='快百货' and wp.IsDeleted = 0
left join dep_kbh_product_test dk on wp.sku =dk.sku
left join  ( select case when NodePathName regexp  '成都' then '成都' else '泉州' end as dep2,SellUserName
    from import_data.mysql_store where department regexp '快') ms on eaapis.SellUserName=ms.SellUserName
)

,t0_seller as (
select spu ,dep2  ,count(distinct SellUserName)  区域SPU分配人数 from t0 group by spu ,dep2  )

,online_lists as ( -- 在线账号清单
select  eaal.sku ,SellUserName  ,CompanyCode  ,SellerSKU,ShopCode ,dep2 ,eaal.spu
from erp_amazon_amazon_listing eaal
join  ( select case when NodePathName regexp  '成都' then '成都' else '泉州' end as dep2,*
    from import_data.mysql_store where department regexp '快') ms on eaal.shopcode=ms.Code and eaal.ListingStatus = 1 and ms.ShopStatus = '正常'
group by eaal.sku ,SellUserName  ,CompanyCode  ,SellerSKU,ShopCode ,dep2 ,eaal.spu
)

,online_comp_stat as ( select sku ,SellUserName ,count(distinct CompanyCode) 在线套数 ,group_concat(CompanyCode)  在线账号代码
   from (select distinct sku ,SellUserName  ,CompanyCode from online_lists ) tmp  group by sku ,SellUserName )
,online_comp_stat_sku_dep2 as ( select sku  ,dep2 ,count(distinct CompanyCode) 区域在线套数_sku
   from (select distinct sku ,dep2  ,CompanyCode from online_lists ) tmp  group by sku,dep2  )
,online_comp_stat_spu as ( select spu   ,count(distinct CompanyCode) 在线套数_spu
   from (select distinct spu   ,CompanyCode from online_lists ) tmp  group by spu  )


,online_lst_stat as ( select sku ,SellUserName ,count(distinct concat(SellerSKU,ShopCode)) 在线条数 from online_lists group by sku ,SellUserName )
,online_lst_stat_sku_dep2 as ( select sku ,dep2 ,count(distinct concat(SellerSKU,ShopCode)) 区域在线条数_sku from online_lists group by sku ,dep2 )
,online_lst_stat_spu as ( select spu  ,count(distinct concat(SellerSKU,ShopCode)) 在线条数_spu from online_lists group by spu  )

,od as (
select TransactionType ,PayTime ,max_refunddate
    ,dep2
    ,wo.Product_Sku as sku ,wo.Product_Spu as spu
    ,round( TotalGross/ExchangeUSD,2) TotalGross_usd_pay
    ,round( TotalProfit/ExchangeUSD ,2) TotalProfit_usd_pay
     ,abs(round( refundamount/ExchangeUSD ,2)) refundamount_usd
    ,FeeGross ,OtherExpend ,TradeCommissions ,PurchaseCosts ,wo.PlatOrderNumber ,OrderStatus ,wo.shopcode ,wo.SellerSku ,wo.asin ,salecount
    ,month(PayTime) pay_month ,BoxSku ,SellUserName
from import_data.wt_orderdetails wo
join ( select case when NodePathName regexp  '成都' then '成都' else '泉州' end as dep2,* from import_data.mysql_store )  ms on wo.shopcode=ms.Code
left join view_kbh_add_refunddate_to_wtord_tmp vr on wo.OrderNumber = vr.OrderNumber
where wo.IsDeleted=0  and ms.Department='快百货' and PayTime  >=date_add('${NextStartDay}',interval -90-1 day)  and PayTime <   date_add( '${NextStartDay}' ,interval -1 day)
)

,od14 as (
select sku ,SellUserName
    ,sum(TotalGross_usd_pay) 近14天销售额S2
    ,sum(TotalProfit_usd_pay) 近14天利润额M2
    ,round( sum(TotalProfit_usd_pay) / sum(TotalGross_usd_pay) ) 近14天利润率R2
    ,sum(salecount) 近14天销量
from od where PayTime  >=date_add('${NextStartDay}',interval -14-1 day)  and PayTime <   date_add( '${NextStartDay}' ,interval -1 day) and TransactionType='付款'
group by sku ,SellUserName
)

,od14_seller as ( -- 用于判断个人近14天是否出单
select  SellUserName
    ,sum(salecount) 近14天销量_人员
from od where PayTime  >=date_add('${NextStartDay}',interval -14-1 day)  and PayTime <   date_add( '${NextStartDay}' ,interval -1 day) and TransactionType='付款'
group by SellUserName
)


,od14_re as ( select sku ,SellUserName ,sum(refundamount_usd) 近14天退款额
from od where max_refunddate  >=date_add('${NextStartDay}',interval -14-1 day)  and max_refunddate <   date_add( '${NextStartDay}' ,interval -1 day) and TransactionType='退款'
group by sku ,SellUserName )
   
,od30_re as ( select sku ,SellUserName ,sum(refundamount_usd) 近30天退款额
from od where max_refunddate  >=date_add('${NextStartDay}',interval -30-1 day)  and max_refunddate <   date_add( '${NextStartDay}' ,interval -1 day) and TransactionType='退款'
group by sku ,SellUserName )

,od30 as (
select sku ,SellUserName
    ,sum(TotalGross_usd_pay) 近30天销售额S2
    ,sum(TotalProfit_usd_pay) 近30天利润额M2
    ,round( sum(TotalProfit_usd_pay) / sum(TotalGross_usd_pay) ) 近30天利润率R2
    ,sum(salecount) 近30天销量
from od where PayTime  >=date_add('${NextStartDay}',interval -30-1 day)  and PayTime <   date_add( '${NextStartDay}' ,interval -1 day) and TransactionType='付款'
group by sku ,SellUserName
)

,od14_sku as (
select sku
    ,sum(salecount) 近14天销量_sku
from od where PayTime  >=date_add('${NextStartDay}',interval -14-1 day)  and PayTime <   date_add( '${NextStartDay}' ,interval -1 day) and TransactionType='付款'
group by sku
)

,ad as ( --
select  waad.shopcode ,waad.SellerSku ,waad.sku ,month(GenerateDate) ad_month
     ,AdSales  , AdSaleUnits 
    , waad.AdClicks , waad.AdExposure  ,waad.AdSpend 
    , AdROAS  ,AdAcost  ,SellUserName
from wt_adserving_amazon_daily waad -- 保留所有打标签链接，并对有曝光数据的链接进行行拆分
join  mysql_store ms on ms.code = waad.ShopCode and ms.Department = '快百货'
    and GenerateDate  >=date_add('${NextStartDay}',interval -14-1 day)  and GenerateDate <  date_add( '${NextStartDay}' ,interval -1 day)
)

, ad14 as (
select tmp.*
    , round(AdClicks/AdExposure,4) as click_rate -- `广告点击率`
    , round(AdSaleUnits/AdClicks,6) as adsale_rate  -- `广告转化率`
    , round(AdSales/AdSpend,2) as ROAS
    , round(AdSpend/AdSales,2) as ACOS
from
    ( select  sku ,SellUserName
        -- 曝光量
        , round(sum(AdExposure)) as AdExposure
        -- 广告花费
        , round(sum(AdSpend),2) as AdSpend
        -- 广告销售额
        , round(sum(AdSales),2) as AdSales
        -- 广告销量
        , round(sum(AdSaleUnits),2) as AdSaleUnits
        -- 点击量
        , round(sum(AdClicks)) as AdClicks
        from ad  group by  sku ,SellUserName
    ) tmp
)

,res as (
select curdate() 数据生成日期 ,a.dep2 区域, NodePathName 小组
, a.SellUserName ,a.spu ,a.sku ,a.boxsku ,a.产品名称 ,a.完整类目 ,a.产品状态 ,a.终审日期 ,a.优先级元素
,b.在线套数 ,c.在线条数 ,在线账号代码
,近14天销量_sku
,round(近14天销售额S2,2) 近14天销售额S2
,近14天销量
,AdExposure 近14天曝光量
,AdClicks 近14天点击量
,click_rate 近14天点击率
,adsale_rate 近14天转化率
,ROAS 近14天ROI
,AdSpend 近14天广告花费
,AdSales 近14天广告销售额
,round( AdSpend /近14天销售额S2 ,4 ) 近14天广告花费占比
,近14天利润率R2
,round( 近14天退款额 / (ifnull(近14天退款额,0) + 近14天销售额S2) ,4 ) 近14天退款率
,round( 近30天销售额S2,2) 近30天销售额S2
,近30天利润率R2
,round( 近30天退款额 / (ifnull(近30天退款额,0) + 近30天销售额S2) ,4 ) 近30天退款率
,产品添加年月
,是否23年7月后添加
,区域SPU分配人数
,区域在线套数_sku
,区域在线条数_sku
,在线套数_spu
,在线条数_spu
,case when 近14天销量_人员 > 0 then '是' else '否' end 近14天是否出单_人员

from t0 a
left join online_comp_stat b on a.sku =b.sku and a.SellUserName = b.SellUserName
left join online_comp_stat_sku_dep2 b2 on a.sku =b2.sku and a.dep2 = b2.dep2
left join online_comp_stat_spu b3 on a.spu =b3.spu
left join online_lst_stat c on a.sku =c.sku and a.SellUserName = c.SellUserName
left join online_lst_stat_sku_dep2 c2 on a.sku =c2.sku and a.dep2 = c2.dep2
left join online_lst_stat_spu c3 on a.spu =c3.spu
left join ( select distinct case when NodePathName regexp  '成都' then '成都' else '泉州' end as dep2,SellUserName,NodePathName
    from import_data.mysql_store where department regexp '快' ) ms on a.SellUserName =ms.SellUserName
left join od14 on a.sku =od14.sku and a.SellUserName = od14.SellUserName  
left join od14_seller on  a.SellUserName = od14_seller.SellUserName
left join od30 on a.sku =od30.sku and a.SellUserName = od30.SellUserName
left join od14_sku on a.sku =od14_sku.sku
left join ad14 on a.sku =ad14.sku and a.SellUserName = ad14.SellUserName
left join od14_re on a.sku =od14_re.sku and a.SellUserName = od14_re.SellUserName
left join od30_re on a.sku =od30_re.sku and a.SellUserName = od30_re.SellUserName
left join t0_seller on a.spu =t0_seller.spu and a.dep2 = t0_seller.dep2 )

select * from res ;
